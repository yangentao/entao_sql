part of 'sql.dart';

// mapXXX, valueXXX, modelXXX
extension QueryResultExt on QueryResult {
  int get columnCount => meta.columns.length;

  // value
  int? firstInt({int col = 0}) => this.firstValueAt(col: col) as int?;

  String? firstString({int col = 0}) => this.firstValueAt(col: col) as String?;

  dynamic firstValueAt({int col = 0}) => this.firstOrNull?[col];

  dynamic firstValueNamed({required String name}) => this.firstOrNull?[labelIndex(name)];

  List<T> allValuesAt<T>({int col = 0}) => this.mapList((e) => e[col] as T);

  List<T> allValuesNamed<T>({required String name}) {
    int col = labelIndex(name);
    return this.mapList((e) => e[col] as T);
  }

  dynamic valueAt({required int row, required int col}) => this[row][col];

  dynamic valueNamed({required int row, required String col}) => this[row][labelIndex(col)];

  // map
  AnyMap? firstMap() => this.isEmpty ? null : mapAt(0);

  AnyMap mapAt(int row) => AnyMap.fromEntries(this[row].mapIndex((i, e) => MapEntry(meta.columns[i].label, e)));

  List<AnyMap> allMaps() => this.mapIndex((i, _) => mapAt(i));

  // model
  T? firstModel<T>(ModelCreator<T> creator) => firstMap()?.let(creator);

  T modelAt<T>(ModelCreator<T> creator, {required int row}) => creator(this.mapAt(row));

  List<T> allModels<T>(ModelCreator<T> creator) => allMaps().mapList(creator);

  // row
  RowData? firstRow() => this.isEmpty ? null : rowAt(0);

  RowData rowAt(int row) => RowData(this[row], meta: meta);

  List<RowData> allRows() => this.mapList((e) => RowData(e, meta: meta));

  void dump() {
    if (this.isEmpty) {
      logSQL.d("[empty]");
    } else {
      for (AnyMap row in this.allMaps()) {
        logSQL.d(row);
      }
    }
  }
}
