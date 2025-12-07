import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:sqlite3/sqlite3.dart';

import '../sql.dart';

class SQliteExecutor extends SQLExecutor {
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
  QueryResult rawQuery(String sql, {AnyList? parameters}) {
    ResultSet rs = lite.rawQuery(sql, parameters);
    return QueryResult(rs.rows, meta: rs.meta, rawResult: rs);
  }

  @override
  void execute(String sql, {AnyList? parameters}) {
    lite.execute(sql, parameters);
  }

  @override
  Future<void> transaction(FutureOr<void> Function() callback) async {
    lite.execute("BEGIN");
    try {
      if (callback case FutureCallback a) {
        await a();
      } else {
        callback();
      }
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
