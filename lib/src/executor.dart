part of 'sql.dart';

abstract interface class SQLExecutor {
  FutureOr<void> execute(String sql, [AnyList? parameters]);

  FutureOr<List<QueryResult>> executeMulti(String sql, Iterable<AnyList> parametersList);

  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]);

  FutureOr<Stream<RowData>> queryStream(String sql, [AnyList? parameters]);

  FutureOr<bool> tableExists(String tableName, [String? schema]);

  FutureOr<Set<String>> tableFields(String tableName, [String? schema]);

  FutureOr<Set<String>> listIndex(String tableName, [String? schema]);

  FutureOr<Set<String>> indexFields(String indexName, [String? schema]);
}

abstract interface class SQLExecutorTx implements SQLExecutor {
  FutureOr<void> transaction(FutureOr<void> Function(SQLExecutor) callback);
}

extension ExpressExecutorExt<T extends Express> on T {
  Future<QueryResult> queryX(SQLExecutor e) async => await e.rawQuery(this.sql, args);
}

String makeIndexName(String table, List<String> fields) {
  var ls = fields.sorted(null);
  return "${table}_${ls.join("_")}";
}
