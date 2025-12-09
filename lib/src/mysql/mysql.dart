import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:mysql_client_plus/mysql_client_plus.dart';

import '../sql.dart';

part 'migrate.dart';
part 'types.dart';

Future<MySQLConnection> mysqlCreateConnection() async {
  MySQLConnection c = await MySQLConnection.createConnection(host: "localhost", port: 3306, userName: "test", password: "test", databaseName: "test");
  await c.connect();
  return c;
}

MySQLConnectionPool mysqlCreatePool() {
  return MySQLConnectionPool(host: "localhost", port: 3306, userName: "root", password: "root", maxConnections: 10);
}

class MySqlPoolExecutor extends SQLExecutorTx {
  final MySQLConnectionPool pool;

  MySqlPoolExecutor(this.pool, {required String database, super.migrator}) : super(defaultSchema: database);

  @override
  FutureOr<int> lastInsertId() async {
    final r = await rawQuery("SELECT LAST_INSERT_ID()");
    return r.firstValue() ?? 0;
  }

  @override
  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) async {
    final st = await pool.prepare(sql, false);
    return await _StatementExecutor(st).multiQuery(parametersList);
  }

  @override
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]) async {
    final st = await pool.prepare(sql, false);
    return await _StatementExecutor(st).rawQuery(parameters);
  }

  @override
  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) async {
    final st = await pool.prepare(sql, true);
    return await _StatementExecutor(st).streamQuery(parameters);
  }

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback) async {
    return await pool.transactional((c) async {
      return await callback(MySqlConnectionExecutor(c, database: this.defaultSchema, migrator: migrator));
    });
  }
}

class MySqlConnectionExecutor extends SQLExecutorTx {
  final MySQLConnection connection;

  MySqlConnectionExecutor(this.connection, {required String database, super.migrator}) : super(defaultSchema: database);

  @override
  FutureOr<int> lastInsertId() async {
    final r = await rawQuery("SELECT LAST_INSERT_ID()");
    return r.firstValue() ?? 0;
  }

  @override
  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) async {
    final st = await connection.prepare(sql, false);
    return await _StatementExecutor(st).multiQuery(parametersList);
  }

  @override
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]) async {
    final st = await connection.prepare(sql, false);
    return await _StatementExecutor(st).rawQuery(parameters);
  }

  @override
  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) async {
    final st = await connection.prepare(sql, true);
    return await _StatementExecutor(st).streamQuery(parameters);
  }

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback) async {
    return connection.transactional((c) async {
      return await callback(this);
    });
  }
}

class _StatementExecutor {
  final PreparedStmt statment;

  _StatementExecutor(this.statment);

  FutureOr<List<QueryResult>> multiQuery(Iterable<AnyList> parametersList) async {
    List<QueryResult> all = [];
    for (AnyList ls in parametersList) {
      IResultSet rs = await statment.execute(ls);
      all.add(rs.queryResult());
    }
    await statment.deallocate();
    return all;
  }

  FutureOr<QueryResult> rawQuery([AnyList? parameters]) async {
    IResultSet rs = await statment.execute(parameters ?? const []);
    final qr = rs.queryResult();
    await statment.deallocate();
    return qr;
  }

  FutureOr<Stream<RowData>> streamQuery([AnyList? parameters]) async {
    IResultSet rs = await statment.execute(parameters ?? const []);
    ResultMeta meta = rs.meta;
    Stream<RowData> s = rs.rowsStream.map((e) {
      AnyList ls = List.filled(e.numOfColumns, null);
      for (int i = 0; i < e.numOfColumns; ++i) {
        ls[i] = e.colAt(i);
      }
      return RowData(ls, meta: meta);
    });
    s.whenComplete(() => statment.deallocate());
    return s;
  }
}

extension on IResultSet {
  ResultMeta get meta => ResultMeta(this.cols.mapIndex((i, e) => ColumnMeta(label: e.name | "[$i]")));

  QueryResult queryResult() {
    List<List<dynamic>> all = [];
    for (ResultSetRow row in this.rows) {
      AnyList ls = List.filled(row.numOfColumns, null);
      for (int i = 0; i < row.numOfColumns; ++i) {
        ls[i] = row.colAt(i);
      }
      all.add(ls);
    }
    return QueryResult(all, meta: meta, rawResult: this, affectedRows: this.affectedRows.toInt());
  }
}
