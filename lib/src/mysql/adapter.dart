import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:mysql1_ext/mysql1_ext.dart';

// import 'package:mysql1/mysql1.dart';

import '../sql.dart';

Future<MySqlConnection> mysqlCreateConnection() async {
  final setting = ConnectionSettings(host: "localhost", port: 3306, user: "test", password: "test", db: "test", useSSL: false, timeout: Duration(seconds: 10));
  return await MySqlConnection.connect(setting);
}

class MySqlConnectionExecutor implements SQLExecutorTx {
  final MySqlConnection connection;
  @override
  final String defaultSchema;

  MySqlConnectionExecutor(this.connection, {required this.defaultSchema});

  @override
  FutureOr<int> lastInsertId() async {
    final r = await rawQuery("SELECT LAST_INSERT_ID()");
    return r.firstInt() ?? 0;
  }

  @override
  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) async {
    List<Results> ls = await connection.queryMulti(sql, parametersList);
    return ls.mapList((rs) => rs.queryResult(affectedRows: rs.affectedRows ?? 0, lastInsertId: 0));
  }

  @override
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]) async {
    Results rs = await connection.query(sql, parameters);
    return rs.queryResult(affectedRows: rs.affectedRows ?? 0, lastInsertId: 0);
  }

  @override
  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) async {
    Results rs = await connection.query(sql, parameters);
    ResultMeta meta = rs.meta;
    return Stream<RowData>.fromIterable(rs.map((e) => RowData(e, meta: meta)));
  }

  @override
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback) async {
    R? r = await connection.transaction((_) async {
      // mysql1  pass the current connection to TransactionContext.
      // so callback with 'this' is OK.
      return await callback(this);
    }, onError: (e) => throw (e));
    return r as R;
  }

  @override
  FutureOr<bool> tableExists(String tableName, [String? schema]) async {
    String sql = "SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?";
    QueryResult r = await rawQuery(sql, [schema | defaultSchema, tableName]);
    return r.isNotEmpty;
  }

  @override
  FutureOr<Set<String>> tableFields(String tableName, [String? schema]) async {
    String sql = "SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?";
    QueryResult r = await rawQuery(sql, [schema | defaultSchema, tableName]);
    int nameIndex = r.labelIndex("COLUMN_NAME");
    return r.map((e) => e[nameIndex] as String).toSet();
  }

  @override
  FutureOr<Set<String>> listIndex(String tableName, [String? schema]) async {
    String sql = "SELECT * FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?";
    QueryResult r = await rawQuery(sql, [schema | defaultSchema, tableName]);
    int nameIndex = r.labelIndex("INDEX_NAME");
    return r.map((e) => e[nameIndex] as String).toSet();
  }

  @override
  FutureOr<Set<String>> indexFields(String tableName, String indexName, [String? schema]) async {
    String sql = "SELECT * FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND INDEX_NAME = ?";
    QueryResult r = await rawQuery(sql, [schema | defaultSchema, tableName, indexName]);
    int nameIndex = r.labelIndex("COLUMN_NAME");
    return r.map((e) => e[nameIndex] as String).toSet();
  }
}

extension on Results {
  ResultMeta get meta => ResultMeta(this.fields.mapIndex((i, e) => ColumnMeta(label: e.name | "[$i]")));

  QueryResult queryResult({int affectedRows = 0, int lastInsertId = 0}) =>
      QueryResult(this.toList(), meta: meta, rawResult: this, affectedRows: affectedRows, lastInsertId: lastInsertId);
}
