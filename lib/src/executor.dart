part of 'sql.dart';

abstract interface class SQLExecutor {
  String get defaultSchema;

  FutureOr<int> lastInsertId() => 0;

  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]);

  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList);

  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]);

  FutureOr<bool> tableExists(String tableName, [String? schema]);

  FutureOr<Set<String>> tableFields(String tableName, [String? schema]);

  FutureOr<Set<String>> listIndex(String tableName, [String? schema]);

  FutureOr<Set<String>> indexFields(String tableName, String indexName, [String? schema]);
}

abstract interface class SQLExecutorTx implements SQLExecutor {
  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback);
}
