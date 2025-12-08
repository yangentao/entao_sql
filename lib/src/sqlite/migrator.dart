part of 'sqlite.dart';

class SQLiteMigrator extends SQLMigrator {
  @override
  Future<void> migrate<T extends TableColumn<T>>(SQLExecutor executor, TableProto<T> tableProto) async {}
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
  String sql = "ALTER TABLE ${table.escapeSQL} ADD COLUMN ${field.defineField(false)}";
  await executor.rawQuery(sql);
}

Future<void> _createTable(SQLExecutor executor, String table, List<TableColumn> fields, {List<String>? constraints, List<String>? options}) async {
  List<String> ls = [];
  ls << "CREATE TABLE IF NOT EXISTS ${table.escapeSQL} (";

  List<String> colList = [];

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

extension _TableColumnDefExt<T extends Enum> on TableColumn<T> {
  String defineField(bool multiKey) {
    List<String> ls = [nameSQL];
    ls << proto.type;
    if (proto.primaryKey && !multiKey) {
      ls << "PRIMARY KEY";
      if (proto.autoInc) {
        ls << "AUTOINCREMENT";
      }
    }
    if (!proto.primaryKey && !multiKey) {
      if (proto.unique) {
        ls << "UNIQUE";
      }
      if (proto.notNull) {
        ls << "NOT NULL";
      }
    }
    if (proto.defaultValue != null && proto.defaultValue!.isNotEmpty) {
      ls << "DEFAULT ${proto.defaultValue}";
    }
    if (proto.check != null && proto.check!.isNotEmpty) {
      ls << "CHECK (${proto.check})";
    }
    if (proto.extras.notBlank) {
      ls << proto.extras!;
    }
    return ls.join(" ");
  }
}
