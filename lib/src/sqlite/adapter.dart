import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:sqlite3/sqlite3.dart';

import '../sql.dart';

class SQliteExecutor extends SQLExecutor {
  LiteSQL lite;

  SQliteExecutor(this.lite);

  @override
  QueryResult query(String sql, {AnyList? parameters}) {
    ResultSet rs = lite.rawQuery(sql, parameters);
    return QueryResult(rs.rows, meta: rs.meta);
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

extension ResultMetaSQLite on ResultSet {
  ResultMeta get meta => ResultMeta(this.columnNames.mapIndex((i, e) => ColumnMeta(label: e, typeId: 0)));
}
