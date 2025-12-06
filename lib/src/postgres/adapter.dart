import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:postgres/postgres.dart' hide Type;

import '../sql.dart';

final _endpoint = Endpoint(host: 'localhost', database: 'test', username: 'test', password: 'test');
final poolPG = Pool.withEndpoints([_endpoint], settings: PoolSettings(sslMode: SslMode.disable));

class PostgresExecutor extends SQLExecutor {
  @override
  FutureOr<QueryResult> query(String sql, {AnyList? parameters}) async {
    Result r = await poolPG.execute(sql, parameters: parameters);
    return QueryResult(r, meta: r.meta);
  }
}

extension ResultMetaPGExt on Result {
  ResultMeta get meta => ResultMeta(this.schema.columns.mapIndex((i, e) => ColumnMeta(label: e.columnName ?? "[$i]", typeId: e.typeOid)));
}
