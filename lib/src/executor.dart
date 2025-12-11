part of 'sql.dart';

abstract interface class SQLExecutor {
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]);

  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList);

  FutureOr<StreamIterator<RowData>> streamQuery(String sql, [AnyList? parameters]);
}

abstract interface class SessionExecutor implements SQLExecutor {
  FutureOr<int> lastInsertId() => 0;
}

abstract interface class TranscationalExecutor implements SQLExecutor {
  FutureOr<R> session<R>(FutureOr<R> Function(SessionExecutor) callback);

  FutureOr<R> transaction<R>(FutureOr<R> Function(SessionExecutor) callback);
}

abstract interface class OnMigrate {
  Future<void> migrate<T extends TableColumn>(SessionExecutor executor, TableProto tableProto);
}

extension ConnectionExecutorTableExt on TranscationalExecutor {
  /// register(Person.values)
  Future<bool> register<T extends TableColumn>(List<T> fields, {OnMigrate? onMigrate}) async {
    return await TableProto.register(fields, executor: this, onMigrate: onMigrate);
  }
}
