part of 'postgres.dart';

class PgMigrator extends SQLMigrator {
  @override
  Future<void> migrate<T extends TableColumn<T>>(SQLExecutor executor, TableProto<T> tableProto) async {
    println("migrate",tableProto.name);
    await _MigratorLite(executor, tableProto).migrate();
  }
}

class _MigratorLite extends UtilMigratorPostgres {
  final SQLExecutor executor;

  // ignore: unused_element_parameter
  _MigratorLite(this.executor, super.tableProto, {super.schema = 'public'});

  @override
  Future<QueryResult> execute(String sql, [AnyList? parameters]) async {
    return await executor.rawQuery(sql, parameters);
  }

  @override
  Future<bool> tableExists() async {
    QueryResult r = await execute(r"SELECT 1 FROM pg_tables WHERE schemaname=$1 AND tablename=$2", [schema ?? "public", tableName]);
    return r.isNotEmpty;
  }

  @override
  Future<Set<String>> tableFields() async {
    String sql = '''
    SELECT a.attname AS field
    FROM pg_class c JOIN pg_attribute a ON a.attrelid = c.oid , pg_namespace as n
    WHERE n.nspname = ? 
    AND c.relname = ?
    AND c.relnamespace = n.oid
    AND a.attnum > 0
    ''';
    QueryResult r = await execute(sql, [schema ?? "public", tableName]);
    return r.map((e) => e[0] as String).toSet();
  }

  @override
  Future<Set<String>> listIndex() async {
    QueryResult r = await execute("SELECT indexname FROM pg_indexes WHERE schemaname=? AND tablename=?", [schema ?? "public", tableName]);
    return r.map((e) => e[0] as String).toSet();
  }

  @override
  Future<Set<String>> indexFields(String indexName) async {
    String sql = '''
    SELECT a.attname AS field
    FROM pg_class c JOIN pg_attribute a ON a.attrelid = c.oid , pg_namespace as n
    WHERE n.nspname = ? 
    AND c.relname = ?
    AND c.relnamespace = n.oid
    AND c.relkind ='i'
    AND a.attnum > 0
    ''';
    QueryResult r = await execute(sql, [schema ?? "public", indexName]);
    return r.map((e) => e[0] as String).toSet();
  }
}
