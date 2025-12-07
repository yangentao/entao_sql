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

void _migrateEnumTable<T extends TableColumn<T>>(SQLExecutor executor, List<T> fields) {
  assert(fields.isNotEmpty);
  if (TableProto.isMigrated<T>()) return;
  TableProto<T> tab = TableProto<T>._(fields.first.tableName, fields, executor: executor);
  _migrateTable(executor, tab.name, tab.columns);
}

void _migrateTable(SQLExecutor executor, String tableName, List<TableColumn> fields) {
  if (!executor.existTable(tableName)) {
    _createTable(executor, tableName, fields);
    return;
  }

  List<SqliteTableInfo> cols = executor.tableInfo(tableName);
  Set<String> colSet = cols.map((e) => e.name).toSet();
  for (TableColumn f in fields) {
    if (!colSet.contains(f.columnName)) {
      _addColumn(executor, tableName, f);
    }
  }
  Set<String> idxSet = {};
  List<LiteIndexItem> idxList = executor.PRAGMA.index_list(tableName);
  for (LiteIndexItem a in idxList) {
    List<LiteIndexInfo> ls = executor.PRAGMA.index_info(a.name);
    idxSet.addAll(ls.map((e) => e.name));
  }
  for (TableColumn f in fields) {
    if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) continue;
    if (f.proto.index && !idxSet.contains(f.columnName)) {
      executor.createIndex(tableName, [f.columnName]);
    }
  }
}

void _addColumn(SQLExecutor executor, String table, TableColumn field) {
  String sql = "ALTER TABLE ${table.escapeSQL} ADD COLUMN ${field.defineField(false)}";
  executor.execute(sql);
}

Future<void> _createTable(SQLExecutor executor, String table, List<TableColumn> fields, {List<String>? constraints, List<String>? options, bool notExist = true}) async {
  ListString ls = [];
  if (notExist) {
    ls << "CREATE TABLE IF NOT EXISTS ${table.escapeSQL} (";
  } else {
    ls << "CREATE TABLE ${table.escapeSQL} (";
  }

  ListString colList = [];

  List<TableColumn> keyFields = fields.filter((e) => e.proto.primaryKey);
  colList.addAll(fields.map((e) => e.defineField(keyFields.length > 1)));

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
  await executor.execute(sql);

  for (var f in fields) {
    if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) {
      continue;
    }
    if (f.proto.index) {
      await executor.createIndex(table, [f.columnName]);
    }
  }
}
