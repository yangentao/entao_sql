part of '../sql.dart';

abstract class SQLMigrate {
  Future<void> imgrate<T extends TableColumn<T>>(SQLExecutor executor, List<T> fields ) async {}
}
