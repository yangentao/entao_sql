part of 'sql.dart';

class QueryResult extends UnmodifiableListView<List<Object?>> {
  final Object rawResult;
  final ResultMeta meta;

  int labelIndex(String label) => meta.labelIndex(label);

  QueryResult(super.source, {required this.meta, required this.rawResult});
}

class ResultMeta {
  final List<ColumnMeta> columns;
  final Map<String, int> labelIndexMap;

  ResultMeta(this.columns) : labelIndexMap = Map.fromEntries(columns.mapIndex((i, e) => MapEntry(e.label, i)));

  int get length => columns.length;

  int labelIndex(String label) => labelIndexMap[label] ?? errorSQL("NO label found");
}

class ColumnMeta {
  final String label;
  final int typeId;

  ColumnMeta({required this.label, this.typeId = 0});
}

//------------------
class RowData extends UnmodifiableListView<Object?> {
  RowData(super.source);
}

abstract interface class CursorResult {
  Iterator<RowData> get iterator;
}
