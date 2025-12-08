part of 'sql.dart';

class TableProto<E extends TableColumn> {
  final String name;
  final List<TableColumn<E>> columns;
  final String nameSQL;
  final SQLExecutor executor;
  late final List<TableColumn<E>> primaryKeys = columns.filter((e) => e.proto.primaryKey);

  TableProto._(this.name, this.columns, {required this.executor}) : nameSQL = name.escapeSQL {
    for (var e in columns) {
      e.tableProto = this;
    }
    _enumTypeMap[E] = this;
  }

  factory TableProto() {
    TableProto? p = _enumTypeMap[E];
    if (p == null) {
      errorSQL("NO table proto of '$E' found, migrate it first. for example: liteSQL.migrate(Person.values) ");
    }
    return p as TableProto<E>;
  }

  TableColumn? find(String fieldName) {
    return columns.firstWhere((e) => e.columnName == fieldName);
  }

  // after migrate
  static TableProto of(Type type) {
    TableProto? p = _enumTypeMap[type];
    if (p == null) {
      errorSQL("NO table proto of $type  found, migrate it first. ");
    }
    return p;
  }

  static bool isMigrated<T>() => _enumTypeMap.containsKey(T);

  static final Map<Type, TableProto> _enumTypeMap = {};
}

TableProto $(Type type) => TableProto.of(type);

TableProto PROTO(Type type) => TableProto.of(type);

extension on Type {
  TableProto get proto => TableProto.of(this);
}

Future<void> _registerTable<T extends TableColumn<T>>(SQLExecutor executor, List<T> fields, {bool migrate = true}) async {
  assert(fields.isNotEmpty);
  if (TableProto.isMigrated<T>()) return;
  TableProto<T> tab = TableProto<T>._(fields.first.tableName, fields, executor: executor);
  if (migrate) {
    await _migrateTable(executor, tab.name, tab.columns);
  }
}

Future<void> _migrateTable(SQLExecutor executor, String tableName, List<TableColumn> fields) async {
  if (!await executor.tableExists(tableName)) {
    _createTable(executor, tableName, fields);
    return;
  }

  Set<String> colSet = await executor.tableFields(tableName);
  for (TableColumn f in fields) {
    if (!colSet.contains(f.columnName)) {
      await _addColumn(executor, tableName, f);
    }
  }
  Set<String> idxSet = {};
  Set<String> idxs = await executor.listIndex(tableName);
  for (String idx in idxs) {
    final fs = await executor.indexFields(tableName, idx);
    idxSet.addAll(fs);
  }
  for (TableColumn f in fields) {
    if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) continue;
    if (f.proto.index && !idxSet.contains(f.columnName)) {
      await _createIndex(executor, tableName, [f.columnName]);
    }
  }
}

Future<void> _createIndex(SQLExecutor executor, String table, List<String> fields) async {
  String idxName = makeIndexName(table, fields);
  String sql = "CREATE INDEX IF NOT EXISTS $idxName ON ${table.escapeSQL} (${fields.map((e) => e.escapeSQL).join(",")})";
  await executor.rawQuery(sql);
}

Future<void> _addColumn(SQLExecutor executor, String table, TableColumn field) async {
  String sql = "ALTER TABLE ${table.escapeSQL} ADD COLUMN ${field.defineField(false, executor.dbType)}";
  await executor.rawQuery(sql);
}

Future<void> _createTable(SQLExecutor executor, String table, List<TableColumn> fields, {List<String>? constraints, List<String>? options}) async {
  List<String> ls = [];
  ls << "CREATE TABLE IF NOT EXISTS ${table.escapeSQL} (";

  List<String> colList = [];

  List<TableColumn> keyFields = fields.filter((e) => e.proto.primaryKey);
  colList.addAll(fields.map((e) => e.defineField(keyFields.length > 1, executor.dbType)));

  if (keyFields.length > 1) {
    colList << "PRIMARY KEY ( ${keyFields.map((e) => e.nameSQL).join(", ")})";
  }
  List<TableColumn> uniqeList = fields.filter((e) => e.proto.uniqueName != null && e.proto.uniqueName!.isNotEmpty);
  if (uniqeList.isNotEmpty) {
    Map<String, List<TableColumn>> map = uniqeList.groupBy((e) => e.proto.uniqueName!);
    for (var e in map.entries) {
      colList << "UNIQUE (${e.value.map((f) => f.nameSQL).join(", ")})";
    }
  }

  if (constraints != null && constraints.isNotEmpty) {
    colList.addAll(constraints);
  }
  ls << colList.join(",\n");
  if (options != null && options.isNotEmpty) {
    ls << ") ${options.join(",")}";
  } else {
    ls << ")";
  }

  String sql = ls.join("\n");
  await executor.rawQuery(sql);

  for (var f in fields) {
    if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) {
      continue;
    }
    if (f.proto.index) {
      await _createIndex(executor, table, [f.columnName]);
    }
  }
}
