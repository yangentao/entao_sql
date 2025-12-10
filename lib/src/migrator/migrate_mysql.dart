part of '../sql.dart';

class OnMigratorMySQL implements OnMigrate {
  final String database;

  OnMigratorMySQL({required this.database});

  @override
  Future<void> migrate<T extends TableColumn>(SessionExecutor executor, TableProto tableProto) async {
    await BasicMySQLMigrator(executor, tableProto, schema: database).migrate();
  }
}

class BasicMySQLMigrator extends BasicMigrator {
  final SessionExecutor executor;

  BasicMySQLMigrator(this.executor, super.tableProto, {required String super.schema});

  @override
  String autoIncDefine(String type) {
    return "$type AUTO_INCREMENT";
  }

  @override
  Future<void> autoIncChangeBase(TableColumn field, int base) async {
    await execute("ALTER TABLE $schemaTable AUTO_INCREMENT = $base");
  }

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
    return r.listValues<String>("COLUMN_NAME").toSet();
  }

  @override
  Future<Set<String>> listIndex() async {
    String sql = "SELECT * FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?";
    QueryResult r = await execute(sql, [schema!, tableName]);
    return r.listValues<String>("INDEX_NAME").toSet();
  }

  @override
  Future<Set<String>> indexFields(String indexName) async {
    String sql = "SELECT * FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND INDEX_NAME = ?";
    QueryResult r = await execute(sql, [schema!, tableName, indexName]);
    return r.listValues<String>("COLUMN_NAME").toSet();
  }
}
