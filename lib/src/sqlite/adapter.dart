import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:sqlite3/sqlite3.dart';

import '../sql.dart';

class SQliteExecutor extends SQLExecutor {
  LiteSQL lite;

  SQliteExecutor(this.lite);

  @override
  FutureOr<QueryResult> query(String sql, {AnyList? parameters}) async {
    LiteSQL lite = LiteSQL.openMemory();
    ResultSet rs = lite.rawQuery(sql, parameters);
    return QueryResult(rs.rows, meta: rs.meta);
  }
}

extension ResultMetaSQLite on ResultSet {
  ResultMeta get meta => ResultMeta(this.columnNames.mapIndex((i, e) => ColumnMeta(label: e, typeId: 0)));
}
