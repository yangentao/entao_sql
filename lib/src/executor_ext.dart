part of 'sql.dart';

extension LiteSqlInsertExt on SQLExecutor {
  /// query([], from:Person)
  /// query(["*"], from:Person)
  /// query([Person.values], from:Person)
  Future<QueryResult> query(
    List<Object> columns, {
    required Object from,
    Object? where,
    Object? groupBy,
    Object? having,
    Object? window,
    Object? orderBy,
    int? limit,
    int? offset,
    List<dynamic>? args,
  }) {
    Express e = SELECT(columns).FROM(from);
    if (where != null) e = e.WHERE(where);
    if (groupBy != null) e = e.GROUP_BY(groupBy);
    if (having != null) e = e.HAVING(having);
    if (window != null) e = e.WINDOWS(window);
    if (orderBy != null) e = e.ORDER_BY(orderBy);
    if (limit != null) {
      e = e.LIMIT(limit);
      if (offset != null) e = e.OFFSET(offset);
    }
    e.addArgs(args);
    return e.query(this);
  }

  Future<RowData?> insert(Object table, {required Iterable<ColumnValue> values, Returning? returning}) async {
    assert(values.isNotEmpty);
    return await insertValues(table, columns: values.map((e) => e.key), values: values.map((e) => e.value), returning: returning);
  }

  Future<RowData?> insertMap(Object table, {required Map<Object, dynamic> values, Returning? returning}) async {
    return await insert(table, values: values.entries, returning: returning);
  }

  Future<RowData?> insertValues(Object table, {required Iterable<Object> columns, required Iterable<dynamic> values, Returning? returning}) async {
    assert(columns.isNotEmpty && values.isNotEmpty && columns.length == values.length);
    returning ??= Returning.ALL;
    SpaceBuffer buf = _insertBuffer(table, columns);
    buf << returning.clause;
    QueryResult rs = await this.rawQuery(buf.toString(), values.toList());
    return rs.firstRow();
  }

  Future<List<RowData>> insertAll(Object table, {required Iterable<List<ColumnValue>> rows, Returning? returning}) async {
    assert(rows.isNotEmpty);
    return await insertAllValues(
      table,
      columns: rows.first.map((e) => e.key),
      rows: rows.map((row) => row.mapList((e) => e.value)),
      returning: returning,
    );
  }

  Future<List<RowData>> insertAllMap(Object table, {required Iterable<Map<Object, dynamic>> rows, Returning? returning}) async {
    return await insertAll(table, rows: rows.map((e) => e.entries.toList()), returning: returning);
  }

  Future<List<RowData>> insertAllValues(
    Object table, {
    required Iterable<Object> columns,
    required Iterable<AnyList> rows,
    Returning? returning,
  }) async {
    assert(columns.isNotEmpty && rows.isNotEmpty);
    returning ??= Returning.ALL;
    SpaceBuffer buf = _insertBuffer(table, columns);
    buf << returning.clause;
    List<QueryResult> ls = await this.multiQuery(buf.toString(), rows);
    return ls.mapList((e) => e.firstRow()!);
  }

  Future<RowData?> upsert(Object table, {required Iterable<ColumnValue> values, required Iterable<Object> constraints, Returning? returning}) async {
    assert(values.isNotEmpty);
    return await upsertValues(table, columns: values.map((e) => e.key), constraints: constraints, values: values.map((e) => e.value), returning: returning);
  }

  Future<RowData?> upsertMap(Object table, {required Map<Object, dynamic> values, required Iterable<Object> constraints, Returning? returning}) async {
    return await upsert(table, values: values.entries, constraints: constraints, returning: returning);
  }

  Future<RowData?> upsertValues(
    Object table, {
    required Iterable<Object> columns,
    required Iterable<Object> constraints,
    required Iterable<dynamic> values,
    Returning? returning,
  }) async {
    assert(columns.isNotEmpty && columns.length == values.length);
    returning ??= Returning.ALL;
    if (constraints.isEmpty) {
      constraints = columns.filter((e) {
        if (e is TableColumn) {
          var p = e.proto;
          return p.primaryKey || p.unique;
        } else {
          return false;
        }
      });
    }

    List<dynamic> valueList = (values is List<dynamic>) ? values : values.toList();

    List<String> columnNames = columns.mapList((e) => _columnNameOf(e));
    List<String> constraintNames = constraints.mapList((e) => _columnNameOf(e));
    List<String> otherNames = columnNames.filter((e) => !constraintNames.contains(e));
    SpaceBuffer buf = _upsertBuffer(table, columnNames, constraints: constraintNames, otherColumns: otherNames);
    var argList = [...values, ...otherNames.mapList((e) => valueList[columnNames.indexOf(e)])];
    buf << returning.clause;
    QueryResult rs = await rawQuery(buf.toString(), argList);
    return rs.firstRow();
  }

  Future<List<RowData>> upsertAll(Object table, {required List<List<ColumnValue>> rows, required Iterable<Object> constraints, Returning? returning}) async {
    return await upsertAllValues(
      table,
      columns: rows.first.map((e) => e.key),
      constraints: constraints,
      rows: rows.mapList((e) => e.mapList((x) => x.value)),
      returning: returning,
    );
  }

  Future<List<RowData>> upsertAllMap(Object table, {required List<Map<Object, dynamic>> rows, required Iterable<Object> constraints, Returning? returning}) async {
    return await upsertAll(table, rows: rows.mapList((e) => e.entries.toList()), constraints: constraints, returning: returning);
  }

  Future<List<RowData>> upsertAllValues(
    Object table, {
    required Iterable<Object> columns,
    required Iterable<Object> constraints,
    required List<List<dynamic>> rows,
    Returning? returning,
  }) async {
    assert(columns.isNotEmpty && rows.isNotEmpty && columns.length == rows[0].length);
    returning ??= Returning.ALL;
    if (constraints.isEmpty) {
      constraints = columns.filter((e) {
        if (e is TableColumn) {
          var p = e.proto;
          return p.primaryKey || p.unique;
        } else {
          return false;
        }
      });
    }

    List<String> columnNames = columns.mapList((e) => _columnNameOf(e));
    List<String> constraintNames = constraints.mapList((e) => _columnNameOf(e));
    List<String> otherNames = columnNames.filter((e) => !constraintNames.contains(e));
    SpaceBuffer buf = _upsertBuffer(table, columnNames, constraints: constraintNames, otherColumns: otherNames);
    buf << returning.clause;
    final argss = rows.map((row) => [...row, ...otherNames.mapList((e) => row[columnNames.indexOf(e)])]);
    List<QueryResult> ls = await multiQuery(buf.toString(), argss);
    return ls.mapList((e) => e.firstRow()!);
  }

  Future<QueryResult> delete(Object table, {required Where where, Returning? returning}) async {
    assert(where.isNotEmpty);
    SpaceBuffer buf = SpaceBuffer("DELETE FROM");
    buf << _tableNameOf(table).escapeSQL;
    buf << "WHERE";
    buf << where.sql;
    if (returning != null) {
      buf << returning.clause;
    }
    return await rawQuery(buf.toString(), where.args);
  }

  Future<QueryResult> update(Object table, {required Iterable<ColumnValue> values, required Where where, Returning? returning}) async {
    return await updateValues(table, columns: values.map((e) => e.key), values: values.map((e) => e.value), where: where, returning: returning);
  }

  Future<QueryResult> updateMap(Object table, {required Map<Object, dynamic> values, required Where where, Returning? returning}) async {
    return await update(table, values: values.entries, where: where, returning: returning);
  }

  Future<QueryResult> updateValues(Object table,
      {required Iterable<Object> columns, required Iterable<dynamic> values, required Where where, Returning? returning}) async {
    assert(columns.isNotEmpty && columns.length == values.length);

    SpaceBuffer buf = SpaceBuffer("UPDATE");
    buf << _tableNameOf(table).escapeSQL;
    buf << "SET";
    buf << columns.map((e) => "${_columnNameOf(e)}=?").join(", ");
    buf << "WHERE";
    buf << where.sql;
    var argList = <dynamic>[...values, ...(where.args)];
    if (returning != null) {
      buf << returning.clause;
    }
    return await rawQuery(buf.toString(), argList);
  }

  void dump(Type table) {
    dumpTable(_tableNameOf(table));
  }

  Future<void> dumpTable(String table) async {
    final r = await rawQuery("SELECT * FROM ${table.escapeSQL}");
    r.dump();
  }


}

SpaceBuffer _insertBuffer(Object table, Iterable<Object> columns) {
  SpaceBuffer buf = SpaceBuffer("INSERT");
  buf << "INTO" << _tableNameOf(table).escapeSQL;
  buf << "(";
  buf << columns.map((e) => _columnNameOf(e).escapeSQL).join(",");
  buf << ") VALUES(";
  buf << columns.map((e) => '?').join(",");
  buf << ")";
  return buf;
}

SpaceBuffer _upsertBuffer(
  Object table,
  Iterable<String> columns, {
  required Iterable<String> constraints,
  required Iterable<String> otherColumns,
}) {
  // List<String> otherColumns = columns.filter((e) => !constraints.contains(e));
  SpaceBuffer buf = SpaceBuffer("INSERT");

  buf << "INTO" << _tableNameOf(table).escapeSQL;
  buf << "(";
  buf << columns.map((e) => e.escapeSQL).join(",");
  buf << ") VALUES(";
  buf << columns.map((e) => '?').join(",");
  buf << ")";
  if (constraints.isNotEmpty) {
    buf << "ON CONFLICT(";
    buf << constraints.map((e) => e.escapeSQL).join(", ");
    if (otherColumns.isEmpty) {
      buf << ") DO NOTHING";
    } else {
      buf << ") DO UPDATE SET";
      buf << otherColumns.map((e) => "${e.escapeSQL}=?").join(", ");
    }
  }
  return buf;
}
