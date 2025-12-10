part of '../sql.dart';

// 顺序必须M在前, 这样可以推导出E的类型
class TableOf<M extends TableModel<E>, E> {
  final M Function(AnyMap) creator;
  late final TableProto proto;

  late final SQLExecutor defaultExecutor = proto.executor;
  late final List<TableColumn> primaryKeys = proto.columns.filter((e) => e.proto.primaryKey);

  TableOf(this.creator) {
    proto = TableProto.of(E);
  }

  String get tableName => proto.name;

  Future<V?> oneValue<V>({required Object column, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, SQLExecutor? executor}) async {
    final r = await this.query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: 1, executor: executor);
    return r.firstValue();
  }

  Future<List<V>> listColumn<V>(
      {required Object column, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset, SQLExecutor? executor}) async {
    final r = await query(
        columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset, executor: executor);
    return r.listValues();
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  Future<M?> oneBy({required Object key, Object? groupBy, Object? having, Object? window, Object? orderBy, SQLExecutor? executor}) async {
    return await oneModel(where: _keyWhere(key), groupBy: groupBy, having: having, window: window, orderBy: orderBy, executor: executor);
  }

  Future<M?> oneModel({Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, SQLExecutor? executor}) async {
    final ls = await listModel(where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: 1, executor: executor);
    return ls.firstOrNull;
  }

  Future<List<M>> listModel({Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset, SQLExecutor? executor}) async {
    final r = await this.query(where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset, executor: executor);
    return r.listModels(creator);
  }

  Future<QueryResult> query(
      {List<Object>? columns, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset, SQLExecutor? executor}) async {
    return (executor ?? defaultExecutor)
        .query(columns ?? [], from: tableName, where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset);
  }

  Future<QueryResult> delete({required Where where, Returning? returning, SQLExecutor? executor}) async {
    return await (executor ?? defaultExecutor).delete(tableName, where: where, returning: returning);
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  Future<QueryResult> deleteBy({required Object key, Returning? returning, SQLExecutor? executor}) async {
    return await delete(where: _keyWhere(key), returning: returning, executor: executor);
  }

  Future<QueryResult> update({required List<ColumnValue> values, required Where where, Returning? returning, SQLExecutor? executor}) async {
    return await (executor ?? defaultExecutor).update(tableName, values: values, where: where, returning: returning);
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  Future<QueryResult> updateBy({required Object key, required List<ColumnValue> values, Returning? returning, SQLExecutor? executor}) async {
    return await (executor ?? defaultExecutor).update(tableName, values: values, where: _keyWhere(key), returning: returning);
  }

  Future<RowData?> upsert({required List<ColumnValue> values, Returning? returning, SQLExecutor? executor}) async {
    return await (executor ?? defaultExecutor).upsert(tableName, values: values, constraints: primaryKeys, returning: returning);
  }

  Future<RowData?> insert({required List<ColumnValue> values, Returning? returning, SQLExecutor? executor}) async {
    if (values.isEmpty) return null;
    return await (executor ?? defaultExecutor).insert(tableName, values: values, returning: returning);
  }

  Future<List<RowData>> insertAll({required List<List<ColumnValue>> rows, Returning? returning, SQLExecutor? executor}) async {
    if (rows.isEmpty) return const [];
    return await (executor ?? defaultExecutor).insertAll(tableName, rows: rows, returning: returning);
  }

  Future<RowData?> save(M? item, {SQLExecutor? executor}) async {
    if (item == null) return null;
    RowData? row = await upsert(values: proto.columns.mapList((e) => e >> e.get(item)), returning: Returning.ALL, executor: executor);
    if (row != null) {
      item.model.addAll(row.toMap());
    }
    return row;
  }

  Future<List<RowData?>> saveAll(List<M> items, {SQLExecutor? executor}) async {
    if (items.isEmpty) return const [];
    List<RowData?> ls = [];
    for (M item in items) {
      ls << await save(item, executor: executor);
    }
    return ls;
  }

  Where _keyWhere(Object value) => _keyEQ(value: value, keys: primaryKeys);

  void dump({SQLExecutor? executor}) {
    (executor ?? defaultExecutor).dumpTable(tableName);
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
