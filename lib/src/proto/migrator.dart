part of '../sql.dart';

abstract class SQLMigrator {
  Future<void> migrate<T extends TableColumn<T>>(SQLExecutor executor, List<T> fields);
}
