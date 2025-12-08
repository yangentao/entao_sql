part of '../sql.dart';

class TableProto<E extends TableColumn> {
  final String name;
  final List<TableColumn<E>> columns;
  final String nameSQL;
  final SQLExecutor executor;
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
}

TableProto $(Type type) => TableProto.of(type);

TableProto PROTO(Type type) => TableProto.of(type);

extension on Type {
  TableProto get proto => TableProto.of(this);
}
