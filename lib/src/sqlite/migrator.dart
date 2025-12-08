part of 'sqlite.dart';

class SQLiteMigrator extends SQLMigrator {
  @override
  Future<void> migrate<T extends TableColumn<T>>(SQLExecutor executor, List<T> fields)  async {

  }
}
