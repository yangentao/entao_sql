part of 'sql.dart';

// mapXXX, valueXXX, modelXXX
extension QueryResultExt on QueryResult {
  int get columnCount => meta.columns.length;

  // value
  /// key is  int index , OR String key
  T? firstValue<T>([Object col = 0]) {
    if (col case int n) return this.firstOrNull?[n] as T?;
    return this.firstOrNull?[labelToIndex(col.toString())] as T?;
  }

  T? oneValue<T>({required int row, Object col = 0}) {
    if (col case int n) return this[row][n] as T?;
    return this[row][labelToIndex(col.toString())] as T?;
  }

  /// col is  int index , OR String key
  List<T> listValues<T>([Object col = 0]) {
    if (col case int n) {
      return this.mapList((e) => e[n] as T);
    }
    int n = labelToIndex(col.toString());
    return this.mapList((e) => e[n] as T);
  }

  // map
  AnyMap? firstMap() => this.isEmpty ? null : oneMap(0);

  AnyMap oneMap(int row) => AnyMap.fromEntries(this[row].mapIndex((i, e) => MapEntry(meta.columns[i].label, e)));

  List<AnyMap> listMaps() => this.mapIndex((i, _) => oneMap(i));

  // model
  T? firstModel<T>(ModelCreator<T> creator) => firstMap()?.let(creator);

  T oneModel<T>(ModelCreator<T> creator, {required int row}) => creator(this.oneMap(row));

  List<T> listModels<T>(ModelCreator<T> creator) => listMaps().mapList(creator);

  // row
  RowData? firstRow() => this.isEmpty ? null : oneRow(0);

  RowData oneRow(int row) => RowData(this[row], meta: meta);

  List<RowData> listRows() => this.mapList((e) => RowData(e, meta: meta));

  void dump() {
    if (this.isEmpty) {
      logSQL.d("[empty]");
    } else {
      for (AnyMap row in this.listMaps()) {
        logSQL.d(row);
      }
    }
  }
}
