import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:println/println.dart';

import '../sql.dart';

part 'migrate.dart';
part 'types.dart';

typedef PGType<T extends Object> = pg.Type<T>;

// final _endpoint = Endpoint(host: 'localhost', database: 'test', username: 'test', password: 'test');
// final poolPG = Pool.withEndpoints([_endpoint], settings: PoolSettings(sslMode: SslMode.disable));

class PostgresPoolExecutor<T> extends PoolExecutor {
  pg.Pool<T> pool;
  PostgresOptions? options;
  late final _PgSessionExecutor _se = _PgSessionExecutor(pool, options: options);

  PostgresPoolExecutor(this.pool, {this.options});

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SessionExecutor) callback) {
    return pool.runTx((session) async {
      return await callback(_PgSessionExecutor(session, options: options));
    }, settings: options?.transactionSettings);
  }

  @override
  FutureOr<R> session<R>(FutureOr<R> Function(SessionExecutor) callback) {
    return pool.run((session) async {
      return await callback(_PgSessionExecutor(session, options: options));
    }, settings: options?.transactionSettings);
  }

  @override
  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) {
    return _se.multiQuery(sql, parametersList);
  }

  @override
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]) {
    return _se.rawQuery(sql, parameters);
  }

  @override
  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) {
    return _se.streamQuery(sql, parameters);
  }
}

class PostgresExecutor implements ConnectionExecutor {
  pg.Connection connection;
  PostgresOptions? options;
  late final _PgSessionExecutor _se = _PgSessionExecutor(connection, options: options);

  PostgresExecutor(this.connection, {this.options});

  @override
  FutureOr<R> session<R>(FutureOr<R> Function(SessionExecutor) callback) async {
    return connection.run((session) async {
      return await callback(_PgSessionExecutor(session, options: options));
    }, settings: options?.transactionSettings);
  }

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SessionExecutor) callback) {
    return connection.runTx((session) async {
      return await callback(_PgSessionExecutor(session, options: options));
    }, settings: options?.transactionSettings);
  }

  @override
  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) {
    return _se.multiQuery(sql, parametersList);
  }

  @override
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]) {
    return _se.rawQuery(sql, parameters);
  }

  @override
  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) {
    return _se.streamQuery(sql, parameters);
  }
}

class _PgSessionExecutor implements SessionExecutor {
  final pg.Session session;
  final PostgresOptions? options;

  _PgSessionExecutor(this.session, {this.options});

  @override
  FutureOr<int> lastInsertId() async {
    final r = await rawQuery("SELECT lastval()");
    return r.firstValue() ?? 0;
  }

  @override
  Future<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) async {
    logSQL.d("streamQuery SQL: ", sql);
    if (parameters?.isNotEmpty == true) {
      logSQL.d(">>>>", parameters);
    }
    pg.Statement st = await session.prepare(sql.paramPositioned);
    Stream<RowData> s = st.bind(parameters).map((r) => RowData(r, meta: r.schema.meta));
    return s.whenComplete(() => st.dispose());
  }

  @override
  Future<QueryResult> rawQuery(String sql, [AnyList? parameters]) async {
    logSQL.d("rawQuery SQL: ", sql);
    if (parameters?.isNotEmpty == true) {
      logSQL.d(">>>>", parameters);
    }
    pg.Result r = await session.execute(sql.paramPositioned, parameters: parameters, timeout: options?.timeout, queryMode: options?.queryMode);
    return r.queryResult(affectedRows: r.affectedRows);
  }

  @override
  Future<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) async {
    logSQL.d("multiQuery SQL: ", sql);
    if (parametersList.isNotEmpty == true) {
      logSQL.d(">>>>", parametersList);
    }
    List<QueryResult> ls = [];
    pg.Statement st = await session.prepare(sql.paramPositioned);
    for (final params in parametersList) {
      pg.Result r = await st.run(params, timeout: options?.timeout);
      ls << r.queryResult(affectedRows: r.affectedRows);
    }
    st.dispose();
    return ls;
  }
}

class PostgresOptions {
  final Duration? timeout;
  final pg.QueryMode? queryMode;
  final pg.TransactionSettings? transactionSettings;

  PostgresOptions({this.timeout, this.queryMode, this.transactionSettings});
}

extension on pg.Result {
  ResultMeta get meta => this.schema.meta;

  QueryResult queryResult({int affectedRows = 0}) => QueryResult(this, meta: meta, rawResult: this, affectedRows: this.affectedRows);
}

extension on pg.ResultSchema {
  ResultMeta get meta => ResultMeta(this.columns.mapIndex((i, e) => ColumnMeta(label: e.columnName ?? "[$i]", typeId: e.typeOid)));
}

extension on String {
  String get paramPositioned {
    StringBuffer buf = StringBuffer();
    int i = 1;
    for (int c in this.codeUnits) {
      if (c == CharCode.QUEST) {
        buf.writeCharCode(CharCode.DOLLAR);
        buf.write("${i++}");
      } else {
        buf.writeCharCode(c);
      }
    }
    return buf.toString();
  }
}
