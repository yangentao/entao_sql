part of 'sqlite.dart';

extension ResultSetExt on ResultSet {
  dynamic firstValue() => this.firstOrNull?.columnAt(0);


  List<AnyMap> listRows() => this.mapList((e) => e.mapSQL);

  List<T> listModels<T>(ModelCreator<T> creator) => listRows().mapList((e) => creator(e));

  void dump() {
    if (this.isEmpty) {
      logSQL.d("[empty]");
      return;
    }
    for (Row r in this) {
      logSQL.d(r.mapSQL);
    }
  }
}

extension RowExt on Row {
  AnyMap get mapSQL {
    AnyMap map = {};
    for (String k in this.keys) {
      map[k] = this[k];
    }
    return map;
  }


}
