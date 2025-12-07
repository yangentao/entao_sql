part of 'sql.dart';

extension QueryResultExt on QueryResult {
  AnyMap rowAt({required int index}) => AnyMap.fromEntries(this[index].mapIndex((i, e) => MapEntry(meta.columns[i].label, e)));

  AnyMap? firstRow() => this.isEmpty ? null : rowAt(index: 0);

  List<AnyMap> listRows() => listMap();

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
