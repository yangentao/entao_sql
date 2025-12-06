part of 'sql.dart';

final _endpoint = Endpoint(host: 'localhost', database: 'test', username: 'test', password: 'test');
final poolPG = Pool.withEndpoints([_endpoint], settings: PoolSettings(sslMode: SslMode.disable));

abstract class SQLExecutor {
  FutureOr<QueryResult> query(String sql, {AnyList? parameters});
}

class SQliteExecutor extends SQLExecutor {
  LiteSQL lite;

  SQliteExecutor(this.lite);

  @override
  FutureOr<QueryResult> query(String sql, {AnyList? parameters}) async {
    LiteSQL lite = LiteSQL.openMemory();
    ResultSet rs = lite.rawQuery(sql, parameters);
    return QueryResult(rs.rows, meta: rs.meta);
  }
}

class PostgresExecutor extends SQLExecutor {
  @override
  FutureOr<QueryResult> query(String sql, {AnyList? parameters}) async {
    Result r = await poolPG.execute(sql, parameters: parameters);
    return QueryResult(r, meta: r.meta);
  }
}

class QueryResult extends UnmodifiableListView<List<Object?>> {
  ResultMeta meta;

  int labelIndex(String label) => meta.labelIndex(label);

  QueryResult(super.source, {required this.meta});
}

class RowData extends UnmodifiableListView<Object?> {
  RowData(super.source);
  // int get length;

  // Object? get(Object key);
}

abstract interface class CursorResult {
  Iterator<RowData> get iterator;
}

class ResultMeta {
  final List<ColumnMeta> columns;
  final Map<String, int> labelIndexMap;

  ResultMeta(this.columns) : labelIndexMap = Map.fromEntries(columns.mapIndex((i, e) => MapEntry(e.label, i)));

  int get length => columns.length;

  int labelIndex(String label) => labelIndexMap[label] ?? errorSQL("NO label found");
}

class ColumnMeta {
  String label;
  int typeId;

  ColumnMeta({required this.label, this.typeId = 0});
}

extension ResultMetaPGExt on Result {
  ResultMeta get meta => ResultMeta(this.schema.columns.mapIndex((i, e) => ColumnMeta(label: e.columnName ?? "[$i]", typeId: e.typeOid)));
}

extension ResultMetaSQLite on ResultSet {
  ResultMeta get meta => ResultMeta(this.columnNames.mapIndex((i, e) => ColumnMeta(label: e, typeId: 0)));
}
