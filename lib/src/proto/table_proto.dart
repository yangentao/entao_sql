part of '../sql.dart';

class TableProto {
  final Type type;

  final String name;
  final List<TableColumn> columns;
  late final String nameSQL = name.escapeSQL;
  final TranscationalExecutor executor;
  late final List<TableColumn> primaryKeys = columns.filter((e) => e.proto.primaryKey);

  TableProto._(this.columns, {required this.executor, required this.type, String? name}) : this.name = (name ?? "$type") {
    for (var e in columns) {
      e._tableProto = this;
    }
    _tableRegisterMap[type] = this;
  }

  factory TableProto(Type type) {
    TableProto? p = _tableRegisterMap[type];
    if (p == null) {
      errorSQL("NO table proto of '$type' found, register it first.");
    }
    return p;
  }

  TableColumn? find(String fieldName) {
    return columns.firstWhere((e) => e.columnName == fieldName);
  }

  // after migrate
  static TableProto of(Type type) {
    TableProto? p = _tableRegisterMap[type];
    if (p == null) {
      errorSQL("NO table proto of $type  found, register it first. ");
    }
    return p;
  }

  static bool isRegisted<T>() => _tableRegisterMap.containsKey(T);

  static final Map<Type, TableProto> _tableRegisterMap = {};

  static Future<bool> register<T extends TableColumn>(List<T> fields, {required TranscationalExecutor executor, String? tableName, OnMigrate? onMigrate}) async {
    assert(fields.isNotEmpty);
    if (TableProto.isRegisted<T>()) return false;
    final tab = TableProto._(fields, type: T, name: tableName, executor: executor);
    if (onMigrate != null) {
      await executor.transaction((e) async {
        await onMigrate.migrate(e, tab);
      });
    }
    return true;
  }
}

TableProto $(Type type) => TableProto.of(type);

TableProto PROTO(Type type) => TableProto.of(type);

extension on Type {
  TableProto get proto => TableProto.of(this);
}
