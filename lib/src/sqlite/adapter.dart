part of 'sqlite.dart';

class SQliteExecutor implements SQLExecutorTx {
  LiteSQL lite;
  @override
  final String defaultSchema;

  SQliteExecutor(this.lite) : this.defaultSchema = "main";

  @override
  FutureOr<int> lastInsertId() => lite.lastInsertRowId;

  @override
  Stream<RowData> streamQuery(String sql, [AnyList? parameters]) async* {
    lite.lastInsertRowId = 0;
    PreparedStatement ps = lite.prepareSQL(sql);
    IteratingCursor ic = ps.selectCursor(parameters ?? const []);
    ResultMeta meta = ic.meta;
    while (ic.moveNext()) {
      yield RowData(ic.current.values, meta: meta);
    }
    ps.close();
  }

  @override
  QueryResult rawQuery(String sql, [AnyList? parameters]) {
    lite.lastInsertRowId = 0;
    return lite.rawQuery(sql, parameters).queryResult(affectedRows: lite.updatedRows, lastInsertId: lite.lastInsertRowId);
  }

  @override
  List<QueryResult> multiQuery(String sql, Iterable<AnyList> parametersList) {
    List<QueryResult> ls = [];
    final st = lite.prepareSQL(sql);
    try {
      for (var params in parametersList) {
        lite.lastInsertRowId = 0;
        ls << st.select(params.toList()).queryResult(affectedRows: lite.updatedRows, lastInsertId: lite.lastInsertRowId);
      }
    } finally {
      st.close();
    }
    return ls;
  }

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback) async {
    lite.execute("BEGIN");
    try {
      final r = await callback(this);
      lite.execute("COMMIT");
      return r;
    } catch (e) {
      lite.execute("ROLLBACK");
      rethrow;
    }
  }

  Set<String> listTable([String? schema]) {
    return lite.PRAGMA.table_list(schema: schema).map((e) => e.name).toSet();
  }

  @override
  bool tableExists(String tableName, [String? schema]) {
    return lite.existTable(tableName);
  }

  @override
  Set<String> tableFields(String tableName, [String? schema]) {
    return lite.PRAGMA.table_info(tableName, schema: schema).map((e) => e.name).toSet();
  }

  @override
  Set<String> listIndex(String tableName, [String? schema]) {
    return lite.PRAGMA.index_list(tableName, schema: schema).map((e) => e.name).toSet();
  }

  @override
  Set<String> indexFields(String tableName, String indexName, [String? schema]) {
    return lite.PRAGMA.index_info(indexName, schema: schema).map((e) => e.name).toSet();
  }
}

extension ResultMetaSQLite on Cursor {
  ResultMeta get meta => ResultMeta(this.columnNames.mapIndex((i, e) => ColumnMeta(label: e, typeId: 0)));
}

extension ResultSetQueryResult on ResultSet {
  QueryResult queryResult({int affectedRows = 0, int lastInsertId = 0}) {
    return QueryResult(rows, meta: meta, rawResult: this, affectedRows: affectedRows, lastInsertId: lastInsertId);
  }
}
