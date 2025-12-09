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

class PgPoolExecutor<T> extends PgSessionExecutor implements SQLExecutorTx {
  pg.Pool<T> pool;

  PgPoolExecutor(this.pool, {PostgresOptions? options, super.migrator}) : super(pool, options: options);

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback) {
    return pool.runTx((session) async {
      return await callback(PgSessionExecutor(session, options: options));
    }, settings: options?.transactionSettings);
  }
}

class PgConnectionExecutor extends PgSessionExecutor implements SQLExecutorTx {
  pg.Connection connection;

  PgConnectionExecutor(this.connection, {PostgresOptions? options, super.migrator}) : super(connection, options: options);

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback) {
    return connection.runTx((session) async {
      return await callback(PgSessionExecutor(session, options: options));
    }, settings: options?.transactionSettings);
  }
}

class PgSessionExecutor extends SQLExecutor {
  final pg.Session session;
  final PostgresOptions? options;

  PgSessionExecutor(this.session, {this.options, super.migrator}) : super(defaultSchema: "public");

  @override
  FutureOr<int> lastInsertId() async {
    final r = await rawQuery("SELECT lastval()");
    return r.firstInt() ?? 0;
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

  Future<Set<String>> listTable([String? schema]) async {
    QueryResult r = await rawQuery("SELECT tablename FROM pg_tables WHERE schemaname=?", [schema ?? "public"]);
    return r.map((e) => e[0] as String).toSet();
  }
}

class PostgresOptions {
  final Duration? timeout;
  final pg.QueryMode? queryMode;
  final pg.TransactionSettings? transactionSettings;

  PostgresOptions({this.timeout, this.queryMode, this.transactionSettings});
}

extension ResultMetaPGExt on pg.Result {
  ResultMeta get meta => this.schema.meta;

  QueryResult queryResult({int affectedRows = 0}) => QueryResult(this, meta: meta, rawResult: this, affectedRows: this.affectedRows);
}

extension ResultMetaResultSchemaExt on pg.ResultSchema {
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
