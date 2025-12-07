import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:entao_log/entao_log.dart';

part 'SpaceBuffer.dart';
part 'TableColumn.dart';
part 'TableModel.dart';
part 'TableOf.dart';
part 'TableProto.dart';
part 'clause/clauses.dart';
part 'clause/express.dart';
part 'clause/ext.dart';
part 'clause/func.dart';
part 'clause/func_win.dart';
part 'clause/joins.dart';
part 'clause/where.dart';
part 'configs.dart';
part 'executor.dart';
part 'executor_ext.dart';
part 'query_result.dart';
part 'query_result_ext.dart';
part 'sql_utils.dart';

typedef FutureCallback = Future<void> Function();
typedef FutureOrCallback = FutureOr<void> Function();

TagLog logSQL = TagLog("SQL");

typedef BlobSQL = Uint8List;

typedef ModelCreator<T> = T Function(AnyMap);
typedef ColumnValue<T extends Object> = MapEntry<T, dynamic>;

final class Returning {
  final List<String> columns;

  Returning([Iterable<Object> columns = const []]) : columns = columns.mapList((e) => _columnNameOf(e));

  String get clause => " RETURNING ${columns.join(", ") | '*'}";

  static Returning get ALL => Returning(const ["*"]);
}

class SQLException implements Exception {
  String message;
  StackTrace stackTrace;

  SQLException(this.message) : stackTrace = StackTrace.current;

  @override
  String toString() {
    return "SQLException: $message .  $stackTrace";
  }
}

Never errorSQL(String message) {
  throw SQLException(message);
}

bool _canSave(dynamic item) {
  return item is TableModel || item is Map<String, dynamic> || item is MapModel;
}

T? _getModelValue<T>(Object model, String name) {
  if (model is TableModel) return model[name];
  if (model is Map<String, dynamic>) return _checkNum(model[name]);
  if (model is MapModel) return _checkNum(model[name].value);
  errorSQL(" get model value failed, unknown container: $model, column: $name.");
}

void _setModelValue(Object model, String key, dynamic value) {
  if (model is TableModel) {
    model[key] = value;
  } else if (model is Map<String, dynamic>) {
    model[key] = value;
  } else if (model is MapModel) {
    model[key] = value;
  } else {
    errorSQL("set value failed, unknown container:$model, tableColumn:$key.");
  }
}

T? _checkNum<T>(dynamic v) {
  if (v == null) return null;
  if (v is num) {
    if (T == int) {
      return v.toInt() as T;
    } else if (T == double) {
      return v.toDouble() as T;
    }
  }
  return v;
}

extension on ColumnValue {
  String get keyName => _columnNameOf(key);
}

String _columnNameOf(Object col) {
  switch (col) {
    case String s:
      return s;
    case TableColumn c:
      return c.columnName;
  }
  errorSQL("Unknown key: $col ");
}

String _tableNameOf(Object table) {
  switch (table) {
    case String s:
      return s;
    case Type t:
      if (t == Object) errorSQL("NO table name");
      return "$t";
  }
  errorSQL("Unknown table: $table ");
}
