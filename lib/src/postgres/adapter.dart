import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:postgres/postgres.dart' hide Type;

import '../sql.dart';

// final _endpoint = Endpoint(host: 'localhost', database: 'test', username: 'test', password: 'test');
// final poolPG = Pool.withEndpoints([_endpoint], settings: PoolSettings(sslMode: SslMode.disable));

class PgPoolExecutor<T> extends PgSessionExecutor implements SQLExecutorTx {
  Pool<T> pool;

  PgPoolExecutor(this.pool, {PostgresOptions? options}) : super(pool, options: options);

  @override
  FutureOr<void> transaction(FutureOr<void> Function(SQLExecutor) callback) {
    pool.runTx((session) async {
      await callback(PgSessionExecutor(session, options: options));
    }, settings: options?.transactionSettings);
  }
}

class PgConnectionExecutor extends PgSessionExecutor implements SQLExecutorTx {
  Connection connection;

  PgConnectionExecutor(this.connection, {PostgresOptions? options}) : super(connection, options: options);

  @override
  FutureOr<void> transaction(FutureOr<void> Function(SQLExecutor) callback) {
    connection.runTx((session) async {
      await callback(PgSessionExecutor(session, options: options));
    }, settings: options?.transactionSettings);
  }
}

class PgSessionExecutor implements SQLExecutor {
  final Session session;
  final PostgresOptions? options;

  PgSessionExecutor(this.session, {this.options});

  @override
  Future<Stream<RowData>> queryStream(String sql, [AnyList? parameters]) async {
    Statement st = await session.prepare(sql);
    Stream<RowData> s = st.bind(parameters).map((r) => RowData(r, meta: r.schema.meta));
    return s.whenComplete(() => st.dispose());
  }

  @override
  Future<QueryResult> rawQuery(String sql, [AnyList? parameters]) async {
    Result r = await session.execute(sql, parameters: parameters, timeout: options?.timeout, queryMode: options?.queryMode);
    return r.queryResult;
  }

  @override
  Future<void> execute(String sql, [AnyList? parameters]) async {
    await session.execute(sql, parameters: parameters, timeout: options?.timeout, ignoreRows: true, queryMode: options?.queryMode);
  }

  @override
  Future<List<QueryResult>> executeMulti(String sql, Iterable<AnyList> parametersList) async {
    List<QueryResult> ls = [];
    Statement st = await session.prepare(sql);
    for (final params in parametersList) {
      Result r = await st.run(params, timeout: options?.timeout);
      ls << r.queryResult;
    }
    st.dispose();
    return ls;
  }
}

class PostgresOptions {
  final Duration? timeout;
  final QueryMode? queryMode;
  final TransactionSettings? transactionSettings;

  PostgresOptions({this.timeout, this.queryMode, this.transactionSettings});
}

extension ResultMetaPGExt on Result {
  ResultMeta get meta => this.schema.meta;

  QueryResult get queryResult => QueryResult(this, meta: meta, rawResult: this);
}

extension ResultMetaResultSchemaExt on ResultSchema {
  ResultMeta get meta => ResultMeta(this.columns.mapIndex((i, e) => ColumnMeta(label: e.columnName ?? "[$i]", typeId: e.typeOid)));
}
