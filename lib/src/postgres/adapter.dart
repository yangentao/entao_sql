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
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback) {
    return pool.runTx((session) async {
      return await callback(PgSessionExecutor(session, options: options));
    }, settings: options?.transactionSettings);
  }
}

class PgConnectionExecutor extends PgSessionExecutor implements SQLExecutorTx {
  Connection connection;

  PgConnectionExecutor(this.connection, {PostgresOptions? options}) : super(connection, options: options);

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback) {
    return connection.runTx((session) async {
      return await callback(PgSessionExecutor(session, options: options));
    }, settings: options?.transactionSettings);
  }
}

class PgSessionExecutor implements SQLExecutor {
  final Session session;
  final PostgresOptions? options;

  PgSessionExecutor(this.session, {this.options});

  @override
  DBType get dbType => DBType.postgres;

  @override
  FutureOr<int> lastInsertId() async {
    final r = await rawQuery("SELECT lastval()");
    return r.firstInt() ?? 0;
  }

  @override
  Future<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) async {
    Statement st = await session.prepare(sql);
    Stream<RowData> s = st.bind(parameters).map((r) => RowData(r, meta: r.schema.meta));
    return s.whenComplete(() => st.dispose());
  }

  @override
  Future<QueryResult> rawQuery(String sql, [AnyList? parameters]) async {
    Result r = await session.execute(sql, parameters: parameters, timeout: options?.timeout, queryMode: options?.queryMode);
    return r.queryResult(affectedRows: r.affectedRows);
  }

  @override
  Future<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) async {
    List<QueryResult> ls = [];
    Statement st = await session.prepare(sql);
    for (final params in parametersList) {
      Result r = await st.run(params, timeout: options?.timeout);
      ls << r.queryResult(affectedRows: r.affectedRows);
    }
    st.dispose();
    return ls;
  }

  Future<Set<String>> listTable([String? schema]) async {
    QueryResult r = await rawQuery("SELECT tablename FROM pg_tables WHERE schemaname=?", [schema ?? "public"]);
    return r.map((e) => e[0] as String).toSet();
  }

  @override
  Future<bool> tableExists(String tableName, [String? schema]) async {
    QueryResult r = await rawQuery("SELECT 1 FROM pg_tables WHERE schemaname=? AND tablename=?", [schema ?? "public", tableName]);
    return r.isNotEmpty;
  }

  @override
  Future<Set<String>> tableFields(String tableName, [String? schema]) async {
    String sql = '''
    SELECT a.attname AS field
    FROM pg_class c JOIN pg_attribute a ON a.attrelid = c.oid , pg_namespace as n
    WHERE n.nspname = ? 
    AND c.relname = ?
    AND c.relnamespace = n.oid
    AND a.attnum > 0
    ''';
    QueryResult r = await rawQuery(sql, [schema ?? "public", tableName]);
    return r.map((e) => e[0] as String).toSet();
  }

  @override
  Future<Set<String>> listIndex(String tableName, [String? schema]) async {
    QueryResult r = await rawQuery("SELECT indexname FROM pg_indexes WHERE schemaname=? AND tablename=?", [schema ?? "public", tableName]);
    return r.map((e) => e[0] as String).toSet();
  }

  @override
  Future<Set<String>> indexFields(String tableName, String indexName, [String? schema]) async {
    String sql = '''
    SELECT a.attname AS field
    FROM pg_class c JOIN pg_attribute a ON a.attrelid = c.oid , pg_namespace as n
    WHERE n.nspname = ? 
    AND c.relname = ?
    AND c.relnamespace = n.oid
    AND c.relkind ='i'
    AND a.attnum > 0
    ''';
    QueryResult r = await rawQuery(sql, [schema ?? "public", indexName]);
    return r.map((e) => e[0] as String).toSet();
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

  QueryResult queryResult({int affectedRows = 0}) => QueryResult(this, meta: meta, rawResult: this, affectedRows: this.affectedRows);
}

extension ResultMetaResultSchemaExt on ResultSchema {
  ResultMeta get meta => ResultMeta(this.columns.mapIndex((i, e) => ColumnMeta(label: e.columnName ?? "[$i]", typeId: e.typeOid)));
}
