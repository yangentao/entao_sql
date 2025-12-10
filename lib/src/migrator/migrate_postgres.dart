part of '../sql.dart';

class OnMigratorPostgres implements OnMigrate {
  final String schema;

  OnMigratorPostgres({this.schema = "public"});

  @override
  Future<void> migrate<T extends TableColumn<T>>(SessionExecutor executor, TableProto<T> tableProto) async {
    println("migrate", tableProto.name);
    await BasicPostgresMigrator(executor, tableProto, schema: schema).migrate();
  }
}

class BasicPostgresMigrator extends BasicMigrator {
  final SessionExecutor executor;

  // ignore: unused_element_parameter
  BasicPostgresMigrator(this.executor, super.tableProto, {super.schema});

  String get schemaOrPublic => schema ?? "public";

  @override
  String autoIncDefine(String type) {
    String t = type.toUpperCase();
    if (t == "SERIAL" || t == "BIGSERIAL" || t == "SMALLSERIAL") return t;
    return "BIGSERIAL";
  }

  @override
  Future<void> autoIncChangeBase(TableColumn field, int base) async {
    final seqName = "${tableName}_${field.name}_seq";
    await execute("ALTER SEQUENCE ${seqName.withSchema(schemaOrPublic)} RESTART WITH $base INCREMENT BY 1");
  }

  @override
  Future<QueryResult> execute(String sql, [AnyList? parameters]) async {
    return await executor.rawQuery(sql, parameters);
  }

  @override
  Future<bool> tableExists() async {
    QueryResult r = await execute(r"SELECT 1 FROM pg_tables WHERE schemaname=$1 AND tablename=$2", [schemaOrPublic, tableName]);
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
    QueryResult r = await execute(sql, [schemaOrPublic, tableName]);
    return r.map((e) => e[0] as String).toSet();
  }

  @override
  Future<Set<String>> listIndex() async {
    QueryResult r = await execute("SELECT indexname FROM pg_indexes WHERE schemaname=? AND tablename=?", [schemaOrPublic, tableName]);
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
    QueryResult r = await execute(sql, [schemaOrPublic, indexName]);
    return r.map((e) => e[0] as String).toSet();
  }
}
