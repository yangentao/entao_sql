part of 'sql.dart';

abstract interface class SQLExecutor {
  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]);

  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList);

  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]);
}

abstract interface class SessionExecutor implements SQLExecutor {
  FutureOr<int> lastInsertId() => 0;
}

abstract interface class ConnectionExecutor implements SQLExecutor {
  FutureOr<R> session<R>(FutureOr<R> Function(SessionExecutor) callback);

  FutureOr<R> transaction<R>(FutureOr<R> Function(SessionExecutor) callback);
}

abstract mixin class PoolExecutor implements SQLExecutor {
  FutureOr<R> session<R>(FutureOr<R> Function(SessionExecutor) callback);

  FutureOr<R> transaction<R>(FutureOr<R> Function(SessionExecutor) callback);
}

abstract class SQLMigrator {
  Future<void> migrate<T extends TableColumn<T>>(SQLExecutor executor, TableProto<T> tableProto);
}

extension ExecutorTableExt on SQLExecutor {
  /// register(Person.values)
  Future<void> register<T extends TableColumn<T>>(List<T> fields, {SQLMigrator? migrator}) async {
    assert(fields.isNotEmpty);
    if (TableProto.isRegisted<T>()) return;
    final tab = TableProto<T>._(fields.first.tableName, fields, executor: this);
    if (migrator != null) {
      if (this case PoolExecutor pe) {
        await pe.session((e) async {
          await migrator.migrate(e, tab);
        });
      } else {
        await migrator.migrate(this, tab);
      }
    }
  }
}
