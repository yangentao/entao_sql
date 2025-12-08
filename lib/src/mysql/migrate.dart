part of 'adapter.dart';

class MySQLMigrator extends SQLMigrator {
  final String database;

  MySQLMigrator(this.database);

  @override
  Future<void> migrate<T extends TableColumn<T>>(SQLExecutor executor, TableProto<T> tableProto) async {
    await _MigratorLite(executor, tableProto, schema: database).migrate();
  }
}

class _MigratorLite extends UtilMigratorSQLite {
  final SQLExecutor executor;

  _MigratorLite(this.executor, super.tableProto, {required String super.schema});

  @override
  Future<QueryResult> execute(String sql, [AnyList? parameters]) async {
    return await executor.rawQuery(sql, parameters);
  }

  @override
  Future<bool> tableExists() async {
    String sql = "SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?";
    QueryResult r = await execute(sql, [schema!, tableName]);
    return r.isNotEmpty;
  }

  @override
  Future<Set<String>> tableFields() async {
    String sql = "SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?";
    QueryResult r = await execute(sql, [schema!, tableName]);
    int nameIndex = r.labelIndex("COLUMN_NAME");
    return r.map((e) => e[nameIndex] as String).toSet();
  }

  @override
  Future<Set<String>> listIndex() async {
    String sql = "SELECT * FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?";
    QueryResult r = await execute(sql, [schema!, tableName]);
    int nameIndex = r.labelIndex("INDEX_NAME");
    return r.map((e) => e[nameIndex] as String).toSet();
  }

  @override
  Future<Set<String>> indexFields(String indexName) async {
    String sql = "SELECT * FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND INDEX_NAME = ?";
    QueryResult r = await execute(sql, [schema!, tableName, indexName]);
    int nameIndex = r.labelIndex("COLUMN_NAME");
    return r.map((e) => e[nameIndex] as String).toSet();
  }
}
