part of 'sql.dart';

abstract interface class SQLExecutor {
  FutureOr<void> execute(String sql, {AnyList? parameters});

  FutureOr<void> executeMulti(String sql, List<AnyList> parametersList);

  FutureOr<QueryResult> rawQuery(String sql, {AnyList? parameters, bool ignoreRows = false});

  FutureOr<Stream<RowData>> queryStream(String sql, {AnyList? parameters});
}

abstract interface class SQLExecutorTx implements SQLExecutor {
  FutureOr<void> transaction(FutureOr<void> Function(SQLExecutor) callback);
}

extension ExpressExecutorExt<T extends Express> on T {
  ResultSet query(LiteSQL lite) => lite.rawQuery(this.sql, args);
}
