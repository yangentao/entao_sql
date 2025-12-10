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

abstract interface class PoolExecutor implements SQLExecutor {
  FutureOr<R> session<R>(FutureOr<R> Function(SessionExecutor) callback);

  FutureOr<R> transaction<R>(FutureOr<R> Function(SessionExecutor) callback);
}

abstract interface class OnMigrate {
  Future<void> migrate<T extends TableColumn<T>>(SessionExecutor executor, TableProto<T> tableProto);
}

extension ConnectionExecutorTableExt on ConnectionExecutor {
  /// register(Person.values)
  Future<void> register<T extends TableColumn<T>>(List<T> fields, {OnMigrate? onMigrate}) async {
    assert(fields.isNotEmpty);
    if (TableProto.isRegisted<T>()) return;
    final tab = TableProto<T>._(fields.first.tableName, fields, executor: this);
    if (onMigrate != null) {
      if (this case SessionExecutor se) {
        await onMigrate.migrate(se, tab);
      } else {
        await this.session((e) async {
          await onMigrate.migrate(e, tab);
        });
      }
    }
  }
}

extension PoolExecutorTableExt on PoolExecutor {
  /// register(Person.values)
  Future<void> register<T extends TableColumn<T>>(List<T> fields, {OnMigrate? onMigrate}) async {
    assert(fields.isNotEmpty);
    if (TableProto.isRegisted<T>()) return;
    final tab = TableProto<T>._(fields.first.tableName, fields, executor: this);
    if (onMigrate != null) {
      if (this case SessionExecutor se) {
        await onMigrate.migrate(se, tab);
      } else {
        await this.session((e) async {
          await onMigrate.migrate(e, tab);
        });
      }
    }
  }
}
