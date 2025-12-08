part of 'sqlite.dart';

class SQLiteMigrator extends SQLMigrator {
  @override
  Future<void> migrate<T extends TableColumn<T>>(SQLExecutor executor, TableProto<T> tableProto) async {
    await _MigratorLite((executor as SQliteExecutor).lite, tableProto).migrate();
  }
}

class _MigratorLite extends UtilMigratorSQLite {
  final LiteSQL lite;

  // ignore: unused_element_parameter
  _MigratorLite(this.lite, super.tableProto, {super.schema});

  @override
  Future<QueryResult> execute(String sql, [AnyList? parameters]) async {
    final r = lite.rawQuery(sql, parameters);
    return r.queryResult();
  }

  @override
  Future<bool> tableExists() async {
    return lite.existTable(tableName);
  }

  @override
  Future<Set<String>> tableFields() async {
    return lite.PRAGMA.table_info(tableName, schema: schema).map((e) => e.name).toSet();
  }

  @override
  Future<Set<String>> listIndex() async {
    return lite.PRAGMA.index_list(tableName, schema: schema).map((e) => e.name).toSet();
  }

  @override
  Future<Set<String>> indexFields(String indexName) async {
    return lite.PRAGMA.index_info(indexName, schema: schema).map((e) => e.name).toSet();
  }
}
