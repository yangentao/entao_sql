part of 'sqlite.dart';

class SQLiteMigrator extends SQLMigrator {
  @override
  Future<void> migrate<T extends TableColumn<T>>(SQLExecutor executor, TableProto<T> tableProto) async {
    _MigratorLite((executor as SQliteExecutor).lite, tableProto).migrate();
  }
}

class _MigratorLite {
  final LiteSQL lite;
  final TableProto tableProto;
  final List<TableColumn> fields;
  final String tableName;
  final String? schema;

  _MigratorLite(this.lite, this.tableProto, {this.schema})
      : tableName = tableProto.name,
        fields = tableProto.columns;

  void migrate() {
    if (!lite.existTable(tableName)) {
      createTable();
      return;
    }

    Set<String> colSet = tableFields();
    for (TableColumn f in fields) {
      if (!colSet.contains(f.columnName)) {
        _addColumn(f);
      }
    }
    Set<String> idxSet = {};
    Set<String> idxs = listIndex();
    for (String idx in idxs) {
      final fs = indexFields(idx);
      idxSet.addAll(fs);
    }
    for (TableColumn f in fields) {
      if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) continue;
      if (f.proto.index && !idxSet.contains(f.columnName)) {
        _createIndex([f.columnName]);
      }
    }
  }

  void createTable({List<String>? constraints, List<String>? options}) {
    SpaceBuffer buf = SpaceBuffer();
    buf << "CREATE TABLE IF NOT EXISTS $tableName (";
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
    lite.rawQuery(buf.toString());

    for (var f in fields) {
      if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) {
        continue;
      }
      if (f.proto.index) {
        _createIndex([f.columnName]);
      }
    }
  }

  void _createIndex(List<String> fields) {
    String idxName = makeIndexName(tableName, fields);
    String sql = "CREATE INDEX IF NOT EXISTS $idxName ON $tableName (${fields.map((e) => e.escapeSQL).join(",")})";
    lite.rawQuery(sql);
  }

  void _addColumn(TableColumn field) {
    String sql = "ALTER TABLE ${tableName.escapeSQL} ADD COLUMN ${defineField(field)}";
    lite.rawQuery(sql);
  }

  bool tableExists([String? schema]) {
    return lite.existTable(tableName);
  }

  Set<String> tableFields([String? schema]) {
    return lite.PRAGMA.table_info(tableName, schema: schema).map((e) => e.name).toSet();
  }

  Set<String> listIndex([String? schema]) {
    return lite.PRAGMA.index_list(tableName, schema: schema).map((e) => e.name).toSet();
  }

  Set<String> indexFields(String indexName, [String? schema]) {
    return lite.PRAGMA.index_info(indexName, schema: schema).map((e) => e.name).toSet();
  }

  String defineField(TableColumn col) {
    ColumnProto proto = col.proto;
    SpaceBuffer buf = SpaceBuffer(col.nameSQL);
    buf << proto.type;
    if (proto.autoInc) {
      buf << "AUTOINCREMENT";
    }
    if (proto.notNull) {
      buf << "NOT NULL";
    }
    if (proto.defaultValue.notEmpty) {
      buf << "DEFAULT ${proto.defaultValue}";
    }
    if (proto.check.notEmpty) {
      buf << "CHECK (${proto.check})";
    }
    if (proto.extras.notBlank) {
      buf << proto.extras!;
    }
    return buf.toString();
  }
}
