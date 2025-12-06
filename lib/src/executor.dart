part of 'sql.dart';

abstract class SQLExecutor {
  FutureOr<QueryResult> query(String sql, {AnyList? parameters});

  FutureOr<void> execute(String sql, {AnyList? parameters});

  FutureOr<void> transaction(FutureOr<void> Function() callback);
}