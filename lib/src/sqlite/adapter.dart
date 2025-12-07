part of 'sqlite.dart';

class SQliteExecutor implements SQLExecutorTx {
  LiteSQL lite;

  SQliteExecutor(this.lite);

  @override
  Stream<RowData> queryStream(String sql, [AnyList? parameters]) async* {
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
    return lite.rawQuery(sql, parameters).queryResult;
  }

  @override
  void execute(String sql, [AnyList? parameters]) {
    lite.execute(sql, parameters);
  }

  @override
  List<QueryResult> executeMulti(String sql, Iterable<AnyList> parametersList) {
    List<QueryResult> ls = [];
    final st = lite.prepareSQL(sql);
    try {
      for (var params in parametersList) {
        ls << st.select(params.toList()).queryResult;
      }
    } finally {
      st.close();
    }
    return ls;
  }

  @override
  Future<void> transaction(FutureOr<void> Function(SQLExecutor) callback) async {
    lite.execute("BEGIN");
    try {
      await callback(this);
      lite.execute("COMMIT");
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
  Set<String> indexFields(String indexName, [String? schema]) {
    return lite.PRAGMA.index_info(indexName, schema: schema).map((e) => e.name).toSet();
  }
}

extension ResultMetaSQLite on Cursor {
  ResultMeta get meta => ResultMeta(this.columnNames.mapIndex((i, e) => ColumnMeta(label: e, typeId: 0)));
}

extension ResultSetQueryResult on ResultSet {
  QueryResult get queryResult {
    return QueryResult(rows, meta: meta, rawResult: this);
  }
}
