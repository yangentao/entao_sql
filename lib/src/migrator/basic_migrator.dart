part of '../sql.dart';

abstract class BasicMigrator {
  final TableProto tableProto;
  final String? schema;
  late final String schemaTable = tableProto.nameSQL.withSchema(schema);

  BasicMigrator(this.tableProto, {this.schema});

  List<TableColumn> get fields => tableProto.columns;

  String get tableName => tableProto.name;

  String autoIncDefine(String type);

  Future<void> autoIncChangeBase(TableColumn field, int base);

  Future<bool> tableExists();

  Future<Set<String>> tableFields();

  Future<Set<String>> listIndex();

  Future<Set<String>> indexFields(String indexName);

  Future<QueryResult> execute(String sql, [AnyList? parameters]);

  Future<void> migrate() async {
    if (!await tableExists()) {
      print("table exists? NO");
      await createTable();
      return;
    }
    Set<String> colSet = await tableFields();
    for (TableColumn f in fields) {
      if (!colSet.contains(f.columnName)) {
        await addColumn(f);
      }
    }
    Set<String> idxSet = {};
    Set<String> idxs = await listIndex();
    for (String idx in idxs) {
      final fs = await indexFields(idx);
      idxSet.addAll(fs);
    }
    for (TableColumn f in fields) {
      if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) continue;
      if (f.proto.index && !idxSet.contains(f.columnName)) {
        await createIndex([f.columnName]);
      }
    }
  }

  Future<void> createTable({List<String>? constraints, List<String>? options}) async {
    SpaceBuffer buf = SpaceBuffer();
    buf << "CREATE TABLE IF NOT EXISTS $schemaTable (";
    buf << fields.joinMap(", ", (e) => defineField(e));

    final pks = fields.filter((e) => e.proto.primaryKey);
    if (pks.isNotEmpty) {
      buf << ", " << "PRIMARY KEY (${pks.map((e) => e.nameSQL).join(", ")})";
    }
    final uniqeList = fields.filter((e) => e.proto.unique || e.proto.uniqueName != null);
    if (uniqeList.isNotEmpty) {
      Map<String, List<TableColumn>> map = uniqeList.groupBy((e) => e.proto.uniqueName | "");
      for (var e in map.entries) {
        if (e.key == "") {
          for (var c in e.value) {
            buf << ", " << "UNIQUE (${c.nameSQL})";
          }
        } else {
          buf << ", " << "CONSTRAINT " << e.key.escapeSQL << " UNIQUE (${e.value.map((f) => f.nameSQL).join(", ")})";
        }
      }
    }

    if (constraints != null && constraints.isNotEmpty) {
      for (var s in constraints) {
        buf << ", " << s;
      }
    }
    buf << ")";
    if (options != null && options.isNotEmpty) {
      buf << options.join(", ");
    }
    await execute(buf.toString());

    final col = fields.firstOr((e) => e.proto.autoInc > 0);
    if (col != null) {
      await autoIncChangeBase(col, col.proto.autoInc);
    }

    for (var f in fields) {
      if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) {
        continue;
      }
      if (f.proto.index) {
        await createIndex([f.columnName]);
      }
    }
  }

  Future<void> createIndex(List<String> fields) async {
    String idxName = makeIndexName(tableName, fields);
    String sql = "CREATE INDEX IF NOT EXISTS $idxName ON $schemaTable (${fields.map((e) => e.escapeSQL).join(",")})";
    await execute(sql);
  }

  Future<void> addColumn(TableColumn field) async {
    String sql = "ALTER TABLE $schemaTable ADD COLUMN ${defineField(field)}";
    await execute(sql);
  }

  String defineField(TableColumn col) {
    ColumnProto proto = col.proto;
    SpaceBuffer buf = SpaceBuffer(col.nameSQL);

    if (proto.autoInc > 0) {
      buf << autoIncDefine(proto.type);
    } else {
      buf << proto.type;
    }
    if (proto.notNull) {
      buf << "NOT NULL";
    }
    if (proto.defaultValue.notEmpty) {
      buf << "DEFAULT" << proto.defaultValue!;
    }
    if (proto.check.notEmpty) {
      buf << "CHECK (" << proto.check! << ")";
    }
    if (proto.extras.notBlank) {
      buf << proto.extras!;
    }
    return buf.toString();
  }
}
