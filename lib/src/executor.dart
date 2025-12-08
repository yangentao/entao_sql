part of 'sql.dart';

abstract class SQLExecutor {
  final String defaultSchema;
  final SQLMigrator? migrator;

  SQLExecutor({required this.defaultSchema, this.migrator});

  FutureOr<int> lastInsertId() => 0;

  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]);

  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList);

  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]);

  FutureOr<bool> tableExists(String tableName, [String? schema]);

  FutureOr<Set<String>> tableFields(String tableName, [String? schema]);

  FutureOr<Set<String>> listIndex(String tableName, [String? schema]);

  FutureOr<Set<String>> indexFields(String tableName, String indexName, [String? schema]);
}

abstract class SQLExecutorTx extends SQLExecutor {
  SQLExecutorTx({required super.defaultSchema, super.migrator});

  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback);
}
