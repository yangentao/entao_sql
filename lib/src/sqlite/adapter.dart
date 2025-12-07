import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:sqlite3/sqlite3.dart';

import '../sql.dart';

class SQliteExecutor implements SQLExecutorTx {
  LiteSQL lite;

  SQliteExecutor(this.lite);

  @override
  Stream<RowData> queryStream(String sql, {AnyList? parameters}) async* {
    PreparedStatement ps = lite.prepareSQL(sql);
    IteratingCursor ic = ps.selectCursor(parameters ?? const []);
    ResultMeta meta = ic.meta;
    while (ic.moveNext()) {
      yield RowData(ic.current.values, meta: meta);
    }
    ps.close();
  }

  @override
  QueryResult rawQuery(String sql, {AnyList? parameters, bool ignoreRows = false}) {
    return lite.rawQuery(sql, parameters).queryResult;
  }

  @override
  void execute(String sql, {AnyList? parameters}) {
    lite.execute(sql, parameters);
  }

  @override
  void executeMulti(String sql, List<AnyList> parametersList) {
    final st = lite.prepareSQL(sql);
    try {
      for (var params in parametersList) {
        st.execute(params);
      }
    } finally {
      st.close();
    }
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
}

extension ResultMetaSQLite on Cursor {
  ResultMeta get meta => ResultMeta(this.columnNames.mapIndex((i, e) => ColumnMeta(label: e, typeId: 0)));
}

extension ResultSetQueryResult on ResultSet {
  QueryResult get queryResult {
    return QueryResult(rows, meta: meta, rawResult: this);
  }
}
