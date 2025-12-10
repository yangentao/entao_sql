part of '../sql.dart';

class OnMigratorSQLite implements OnMigrate {
  final String schema;

  OnMigratorSQLite({this.schema = 'main'});

  @override
  Future<void> migrate<T extends TableColumn>(SessionExecutor executor, TableProto<T> tableProto) async {
    await BasicSQLiteMigrator(executor, tableProto, schema: schema).migrate();
  }
}

class BasicSQLiteMigrator extends BasicMigrator {
  final SessionExecutor executor;

  // ignore: unused_element_parameter
  BasicSQLiteMigrator(this.executor, super.tableProto, {super.schema});

  @override
  String autoIncDefine(String type) {
    return "$type AUTOINCREMENT";
  }

  @override
  Future<void> autoIncChangeBase(TableColumn field, int base) async {
    final seqTable = "sqlite_sequence".withSchema(schema);
    final tab = tableName.escapeSQL;
    final rs = await this.execute("SELECT name, seq FROM $seqTable WHERE name = $tab");
    if (rs.isNotEmpty) {
      this.execute("UPDATE $seqTable SET seq = $base WHERE name = $tab");
    } else {
      this.execute("INSERT INTO $seqTable(name, seq) VALUES( $tab, $base)");
    }
  }

  @override
  Future<QueryResult> execute(String sql, [AnyList? parameters]) async {
    return await executor.rawQuery(sql, parameters);
  }

  @override
  Future<bool> tableExists() async {
    String sql = "SELECT 1 FROM ${"sqlite_schema".withSchema(schema)} WHERE type = 'table' AND name = ?";
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
