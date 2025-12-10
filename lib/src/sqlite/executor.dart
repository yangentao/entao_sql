part of 'sqlite.dart';

class SQliteExecutor implements ConnectionExecutor, SessionExecutor {
  LiteSQL lite;

  SQliteExecutor(this.lite);

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
    return lite.rawQuery(sql, parameters).queryResult(affectedRows: lite.updatedRows);
  }

  @override
  List<QueryResult> multiQuery(String sql, Iterable<AnyList> parametersList) {
    List<QueryResult> ls = [];
    final st = lite.prepareSQL(sql);
    try {
      for (var params in parametersList) {
        lite.lastInsertRowId = 0;
        ls << st.select(params.toList()).queryResult(affectedRows: lite.updatedRows);
      }
    } finally {
      st.close();
    }
    return ls;
  }

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SessionExecutor) callback) async {
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

  @override
  FutureOr<R> session<R>(FutureOr<R> Function(SessionExecutor) callback) async {
    return await callback(this);
  }
}

extension ResultMetaSQLite on Cursor {
  ResultMeta get meta => ResultMeta(this.columnNames.mapIndex((i, e) => ColumnMeta(label: e, typeId: 0)));
}

extension ResultSetQueryResult on ResultSet {
  QueryResult queryResult({int affectedRows = 0}) {
    return QueryResult(rows, meta: meta, rawResult: this, affectedRows: affectedRows);
  }
}
