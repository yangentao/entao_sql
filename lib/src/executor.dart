part of 'sql.dart';

abstract mixin class SQLExecutor {
  FutureOr<void> execute(String sql, {AnyList? parameters});

  FutureOr<QueryResult> rawQuery(String sql, {AnyList? parameters});

  FutureOr<Stream<RowData>> queryStream(String sql, {AnyList? parameters});

  // TODO 回调带参数
  FutureOr<void> transaction(FutureOr<void> Function() callback);
}

extension ExpressExecutorExt<T extends Express> on T {
  ResultSet query(LiteSQL lite) => lite.rawQuery(this.sql, args);
}
