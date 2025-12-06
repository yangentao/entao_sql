import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:postgres/postgres.dart' hide Type;

import '../sql.dart';

// final _endpoint = Endpoint(host: 'localhost', database: 'test', username: 'test', password: 'test');
// final poolPG = Pool.withEndpoints([_endpoint], settings: PoolSettings(sslMode: SslMode.disable));

class PostgresExecutor<T> extends SQLExecutor {
  final SessionExecutor executor;
  final Duration? timeout;
  final QueryMode? queryMode;
  final TransactionSettings? transactionSettings;
  Session? _session;

  PostgresExecutor(this.executor, {this.timeout, this.queryMode, this.transactionSettings});

  @override
  Future<QueryResult> query(String sql, {AnyList? parameters}) async {
    if (_session case Session se) {
      Result r = await se.execute(sql, parameters: parameters, timeout: timeout, queryMode: queryMode);
      return QueryResult(r, meta: r.meta, rawResult: r);
    } else {
      return executor.run((se) async {
        Result r = await se.execute(sql, parameters: parameters, timeout: timeout, queryMode: queryMode);
        return QueryResult(r, meta: r.meta, rawResult: r);
      }, settings: SessionSettings(queryTimeout: timeout, queryMode: queryMode));
    }
  }

  @override
  Future<void> execute(String sql, {AnyList? parameters}) async {
    if (_session case Session se) {
      await se.execute(sql, parameters: parameters, timeout: timeout, ignoreRows: true, queryMode: queryMode);
    } else {
      return executor.run((se) async {
        await se.execute(sql, parameters: parameters, timeout: timeout, ignoreRows: true, queryMode: queryMode);
      }, settings: SessionSettings(queryTimeout: timeout, queryMode: queryMode));
    }
  }

  @override
  Future<void> transaction(FutureOr<void> Function() callback) async {
    executor.runTx((session) async {
      _session = session;
      try {
        await callback();
      } finally {
        _session = null;
      }
    }, settings: transactionSettings);
  }
}

extension ResultMetaPGExt on Result {
  ResultMeta get meta => ResultMeta(this.schema.columns.mapIndex((i, e) => ColumnMeta(label: e.columnName ?? "[$i]", typeId: e.typeOid)));
}
