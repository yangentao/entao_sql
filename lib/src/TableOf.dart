part of 'sql.dart';

// 顺序必须M在前, 这样可以推导出E的类型
class TableOf<M extends TableModel<E>, E extends TableColumn> {
  final M Function(AnyMap) creator;
  late final TableProto<E> proto = TableProto<E>();
  late final SQLExecutor executor = proto.executor;
  late final List<TableColumn> primaryKeys = proto.columns.filter((e) => e.proto.primaryKey);

  TableOf(this.creator);

  String get tableName => proto.name;

  Future<V?> oneValue<V>({required Object column, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy}) async {
    final r = await this.query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: 1);
    return r.firstValue();
  }

  Future<List<V>> listColumn<V>({required Object column, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset}) async {
    final r = await query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset);
    return r.listValues();
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  Future<M?> oneBy({required Object key, Object? groupBy, Object? having, Object? window, Object? orderBy}) async {
    return await oneModel(where: _keyWhere(key), groupBy: groupBy, having: having, window: window, orderBy: orderBy);
  }

  Future<M?> oneModel({Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy}) async {
    final ls = await listModel(where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: 1);
    return ls.firstOrNull;
  }

  Future<List<M>> listModel({Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset}) async {
    final r = await this.query(where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset);
    return r.listModels(creator);
  }

  Future<QueryResult> query({List<Object>? columns, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset}) async {
    return executor.query(columns ?? [], from: tableName, where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset);
  }

  Future<QueryResult> delete({required Where where, Returning? returning}) async {
    return await executor.delete(tableName, where: where, returning: returning);
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  Future<QueryResult> deleteBy({required Object key, Returning? returning}) async {
    return await delete(where: _keyWhere(key), returning: returning);
  }

  Future<QueryResult> update({required List<ColumnValue> values, required Where where, Returning? returning}) async {
    return await executor.update(tableName, values: values, where: where, returning: returning);
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  Future<QueryResult> updateBy({required Object key, required List<ColumnValue> values, Returning? returning}) async {
    return await executor.update(tableName, values: values, where: _keyWhere(key), returning: returning);
  }

  Future<RowData?> upsert({required List<ColumnValue> values, Returning? returning}) async {
    return await executor.upsert(tableName, values: values, constraints: primaryKeys, returning: returning);
  }

  Future<RowData?> insert({required List<ColumnValue> values, Returning? returning}) async {
    if (values.isEmpty) return null;
    return await executor.insert(tableName, values: values, returning: returning);
  }

  Future<List<RowData>> insertAll({required List<List<ColumnValue>> rows, Returning? returning}) async {
    if (rows.isEmpty) return const [];
    return await executor.insertAll(tableName, rows: rows, returning: returning);
  }

  Future<RowData?> save(M? item) async {
    if (item == null) return null;
    RowData? row = await upsert(values: proto.columns.mapList((e) => e >> e.get(item)), returning: Returning.ALL);
    if (row != null) {
      item.model.addAll(row.toMap());
    }
    return row;
  }

  Future<List<RowData?>> saveAll(List<M> items) async {
    if (items.isEmpty) return const [];
    List<RowData?> ls = [];
    for (M item in items) {
      ls << await save(item);
    }
    return ls;
  }

  Where _keyWhere(Object value) => _keyEQ(value: value, keys: primaryKeys);

  void dump() {
    executor.dumpTable(tableName);
  }
}

Where _keyEQ({required Object value, required List<TableColumn> keys}) {
  if (value is Where) return value;
  if (keys.isEmpty) errorSQL("No Primary Key defined");
  if (value is List<dynamic>) {
    List<dynamic> values = value.nonNullList;
    if (keys.length != values.length) errorSQL("Primary Keys has different size of given values");
    return keys.mapIndex((n, e) => e.EQ(values[n])).and();
  } else {
    if (keys.length != 1) errorSQL("Primary Key count MUST be one");
    return keys.first.EQ(value);
  }
}
