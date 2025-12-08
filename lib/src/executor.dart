part of 'sql.dart';

abstract class SQLExecutor {
  final String defaultSchema;
  final SQLMigrator? migrator;

  SQLExecutor({required this.defaultSchema, this.migrator});

  FutureOr<int> lastInsertId() => 0;

  FutureOr<QueryResult> rawQuery(String sql, [AnyList? parameters]);

  FutureOr<List<QueryResult>> multiQuery(String sql, Iterable<AnyList> parametersList);

  FutureOr<Stream<RowData>> streamQuery(String sql, [AnyList? parameters]);
}

abstract class SQLExecutorTx extends SQLExecutor {
  SQLExecutorTx({required super.defaultSchema, super.migrator});

  FutureOr<R> transaction<R>(FutureOr<R> Function(SQLExecutor) callback);
}

abstract class SQLMigrator {
  Future<void> migrate<T extends TableColumn<T>>(SQLExecutor executor, TableProto<T> tableProto);
}

extension ExecutorTableExt on SQLExecutor {
  /// register(Person.values)
  Future<void> register<T extends TableColumn<T>>(List<T> fields, {bool migrate = true}) async {
    assert(fields.isNotEmpty);
    if (TableProto.isRegisted<T>()) return;
    final tab = TableProto<T>._(fields.first.tableName, fields, executor: this);
    if (migrate) {
      SQLMigrator? m = this.migrator;
      if (m != null) {
        await m.migrate(this, tab);
      }
    }
  }
}
