import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:mysql1_ext/mysql1_ext.dart';

import '../sql.dart';

part 'migrate.dart';
part 'types.dart';

Future<MySqlConnection> mysqlCreateConnection() async {
  final setting = ConnectionSettings(host: "localhost", port: 3306, user: "test", password: "test", db: "test", useSSL: false, timeout: Duration(seconds: 10));
  return await MySqlConnection.connect(setting);
}

class MySqlPoolExecutor extends SQLExecutorTx {
  final MySqlConnectionPool pool;

  MySqlPoolExecutor(this.pool, {required String database, super.migrator}) : super(defaultSchema: database);

  @override
  FutureOr<int> lastInsertId() async {
    final r = await rawQuery("SELECT LAST_INSERT_ID()");
    return r.firstInt() ?? 0;
  }

  @override
  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) async {
    List<Results> ls = await pool.queryMulti(sql, parametersList);
    return ls.mapList((rs) => rs.queryResult());
  }

  @override
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]) async {
    Results rs = await pool.query(sql, parameters);
    return rs.queryResult();
  }

  @override
  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) async {
    Results rs = await pool.query(sql, parameters);
    ResultMeta meta = rs.meta;
    return Stream<RowData>.fromIterable(rs.map((e) => RowData(e, meta: meta)));
  }

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback) async {
    R? r = await pool.transaction((ctx) async {
      return await callback(_MySqlContextExecutor(ctx, database: defaultSchema, migrator: migrator));
    }, onError: (e) => throw (e));
    return r as R;
  }
}

class MySqlConnectionExecutor extends SQLExecutorTx {
  final MySqlConnection connection;

  MySqlConnectionExecutor(this.connection, {required String database, super.migrator}) : super(defaultSchema: database);

  @override
  FutureOr<int> lastInsertId() async {
    final r = await rawQuery("SELECT LAST_INSERT_ID()");
    return r.firstInt() ?? 0;
  }

  @override
  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) async {
    List<Results> ls = await connection.queryMulti(sql, parametersList);
    return ls.mapList((rs) => rs.queryResult());
  }

  @override
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]) async {
    Results rs = await connection.query(sql, parameters);
    return rs.queryResult();
  }

  @override
  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) async {
    Results rs = await connection.query(sql, parameters);
    ResultMeta meta = rs.meta;
    return Stream<RowData>.fromIterable(rs.map((e) => RowData(e, meta: meta)));
  }

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback) async {
    R? r = await connection.transaction((ctx) async {
      return await callback(_MySqlContextExecutor(ctx, database: defaultSchema, migrator: migrator));
    }, onError: (e) => throw (e));
    return r as R;
  }
}

class _MySqlContextExecutor extends SQLExecutor {
  final TransactionContext txContext;

  _MySqlContextExecutor(this.txContext, {required String database, super.migrator}) : super(defaultSchema: database);

  @override
  FutureOr<int> lastInsertId() async {
    final r = await rawQuery("SELECT LAST_INSERT_ID()");
    return r.firstInt() ?? 0;
  }

  @override
  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) async {
    List<Results> ls = await txContext.queryMulti(sql, parametersList);
    return ls.mapList((rs) => rs.queryResult());
  }

  @override
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]) async {
    Results rs = await txContext.query(sql, parameters);
    return rs.queryResult();
  }

  @override
  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) async {
    Results rs = await txContext.query(sql, parameters);
    ResultMeta meta = rs.meta;
    return Stream<RowData>.fromIterable(rs.map((e) => RowData(e, meta: meta)));
  }
}

extension on Results {
  ResultMeta get meta => ResultMeta(this.fields.mapIndex((i, e) => ColumnMeta(label: e.name | "[$i]")));

  QueryResult queryResult() => QueryResult(this.toList(), meta: meta, rawResult: this, affectedRows: this.affectedRows ?? 0);
}
