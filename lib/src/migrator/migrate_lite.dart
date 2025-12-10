part of '../sql.dart';

class SQLiteMigrator implements SQLMigrator {
  @override
  Future<void> migrate<T extends TableColumn<T>>(SessionExecutor executor, TableProto<T> tableProto) async {
    await _MigratorLite(executor, tableProto).migrate();
  }
}

class _MigratorLite extends UtilMigratorSQLite {
  final SessionExecutor executor;

  // ignore: unused_element_parameter
  _MigratorLite(this.executor, super.tableProto, {super.schema});

  @override
  Future<QueryResult> execute(String sql, [AnyList? parameters]) async {
    return await executor.rawQuery(sql, parameters);
  }

  @override
  Future<bool> tableExists() async {
    String sql = "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?";
    QueryResult rs = await executor.rawQuery(sql, [tableName]);
    return rs.isNotEmpty;
  }

  @override
  Future<Set<String>> tableFields() async {
    QueryResult r = await executor.rawQuery("PRAGMA ${"table_info".withSchema(schema)}($tableName)");
    return r.listValues<String>("name").toSet();
  }

  @override
  Future<Set<String>> listIndex() async {
    QueryResult r = await executor.rawQuery("PRAGMA ${"index_list".withSchema(schema)}($tableName)");
    return r.listValues<String>("name").toSet();
  }

  @override
  Future<Set<String>> indexFields(String indexName) async {
    QueryResult r = await executor.rawQuery("PRAGMA ${"index_info".withSchema(schema)}($indexName)");
    return r.listValues<String>("name").toSet();
  }
}
