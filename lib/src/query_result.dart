part of 'sql.dart';

class QueryResult extends UnmodifiableListView<List<Object?>> {
  final int affectedRows;
  final ResultMeta meta;
  final Object? rawResult;

  int labelIndex(String label) => meta.labelIndex(label);

  QueryResult(List<List<Object?>> super.source, {required this.meta, this.rawResult, this.affectedRows = 0});
}

class ResultMeta {
  final List<ColumnMeta> columns;
  final Map<String, int> labelIndexMap;

  ResultMeta(this.columns) : labelIndexMap = Map.fromEntries(columns.mapIndex((i, e) => MapEntry(e.label, i)));

  int get length => columns.length;

  int labelIndex(String label) => labelIndexMap[label] ?? errorSQL("NO label found");
}

// TODO add Type type property.
class ColumnMeta {
  final String label;
  final int typeId;

  ColumnMeta({required this.label, this.typeId = 0});
}

//------------------
class RowData extends UnmodifiableListView<Object?> {
  final ResultMeta meta;

  RowData(super.source, {required this.meta});

  int labelIndex(String label) => meta.labelIndex(label);

  Object? named(String label) => this[labelIndex(label)];

  AnyMap toMap() => AnyMap.fromEntries(this.mapIndex((i, e) => MapEntry(meta.columns[i].label, e)));
}
