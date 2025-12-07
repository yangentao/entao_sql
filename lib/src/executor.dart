part of 'sql.dart';

abstract class SQLExecutor {
  FutureOr<void> execute(String sql, {AnyList? parameters});

  FutureOr<QueryResult> query(String sql, {AnyList? parameters});

  FutureOr<Stream<RowData>> queryStream(String sql, {AnyList? parameters});

  FutureOr<void> transaction(FutureOr<void> Function() callback);
}
