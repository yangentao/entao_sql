part of '../sql.dart';

class TableProto<E extends TableColumn> {
  final String name;
  final List<TableColumn<E>> columns;
  final String nameSQL;
  final TranscationalExecutor executor;
  late final List<TableColumn<E>> primaryKeys = columns.filter((e) => e.proto.primaryKey);

  TableProto._(this.name, this.columns, {required this.executor}) : nameSQL = name.escapeSQL {
    for (var e in columns) {
      e.tableProto = this;
    }
    _tableRegisterMap[E] = this;
  }

  factory TableProto() {
    TableProto? p = _tableRegisterMap[E];
    if (p == null) {
      errorSQL("NO table proto of '$E' found, migrate it first. for example: liteSQL.migrate(Person.values) ");
    }
    return p as TableProto<E>;
  }

  TableColumn? find(String fieldName) {
    return columns.firstWhere((e) => e.columnName == fieldName);
  }

  // after migrate
  static TableProto of(Type type) {
    TableProto? p = _tableRegisterMap[type];
    if (p == null) {
      errorSQL("NO table proto of $type  found, migrate it first. ");
    }
    return p;
  }

  static bool isRegisted<T>() => _tableRegisterMap.containsKey(T);

  static final Map<Type, TableProto> _tableRegisterMap = {};

  static Future<bool> register<T extends TableColumn<T>>(List<T> fields, {required TranscationalExecutor executor, OnMigrate? onMigrate}) async {
    assert(fields.isNotEmpty);
    if (TableProto.isRegisted<T>()) return false;
    final tab = TableProto<T>._(fields.first.tableName, fields, executor: executor);
    if (onMigrate != null) {
      await executor.session((e) async {
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
