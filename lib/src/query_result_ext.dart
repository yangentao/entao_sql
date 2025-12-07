part of 'sql.dart';

// mapXXX, valueXXX, modelXXX
extension QueryResultExt on QueryResult {
  int get columnCount => meta.columns.length;

  RowData rowDataAt(int index) => RowData(this[index], meta: meta);

  RowData? get firstRowData => this.isEmpty ? null : rowDataAt(0);

  AnyMap rowAt({required int index}) => AnyMap.fromEntries(this[index].mapIndex((i, e) => MapEntry(meta.columns[i].label, e)));

  AnyMap? firstRow() => this.isEmpty ? null : rowAt(index: 0);

  List<AnyMap> listRows() => listMap();

  Object? valueAt({required int row, required int col}) => this[row][col];

  Object? valueNamed({required int row, required String col}) => this[row][labelIndex(col)];

  dynamic firstValue() => this.firstOrNull?.firstOrNull;

  List<T> listValues<T>({int col = 0}) => this.mapList((e) => e[col] as T);

  T modelAt<T>(ModelCreator<T> creator, {required int row}) => creator(this.rowAt(index: row));

  T? firstModel<T>(ModelCreator<T> creator) => firstRow()?.let((e) => creator(e));

  List<T> listModels<T>(ModelCreator<T> creator) => listRows().mapList((e) => creator(e));

  void dump() {
    if (this.isEmpty) {
      logSQL.d("[empty]");
    } else {
      for (AnyMap row in this.listMap()) {
        logSQL.d(row);
      }
    }
  }
}
