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

  MySqlConnectionExecutor(this.connection);

  @override
  DBType get dbType => DBType.mysql;

  @override
  FutureOr<Set<String>> indexFields(String indexName, [String? schema]) {
    // TODO: implement indexFields
    throw UnimplementedError();
  }

  @override
  FutureOr<Set<String>> listIndex(String tableName, [String? schema]) {
    // TODO: implement listIndex
    throw UnimplementedError();
  }

  @override
  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList) async {
    List<Results> ls = await connection.queryMulti(sql, parametersList);
    return ls.mapList((rs) => rs.queryResult);
  }

  @override
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]) async {
    Results rs = await connection.query(sql, parameters);
    return rs.queryResult;
  }

  @override
  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]) async {
    Results rs = await connection.query(sql, parameters);
    ResultMeta meta = rs.meta;
    return Stream<RowData>.fromIterable(rs.map((e) => RowData(e, meta: meta)));
  }

  @override
  FutureOr<bool> tableExists(String tableName, [String? schema]) {
    // TODO: implement tableExists
    throw UnimplementedError();
  }

  @override
  FutureOr<Set<String>> tableFields(String tableName, [String? schema]) {
    // TODO: implement tableFields
    throw UnimplementedError();
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
}

extension on Results {
  ResultMeta get meta => ResultMeta(this.fields.mapIndex((i, e) => ColumnMeta(label: e.name | "[$i]")));

  QueryResult get queryResult => QueryResult(this.toList(), meta: meta, rawResult: this);
}
