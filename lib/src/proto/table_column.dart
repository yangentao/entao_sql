part of '../sql.dart';

/// don't use 'name', use 'columnName',  enum's name maybe renamed.
mixin TableColumn on Enum {
  ColumnProto get proto;

  String get tableName => tableProto.name;

  String get columnName => _ensureColumnProperty(this, "columnName", () => (proto.name ?? this.name).toLowerCase());

  String get nameSQL => _ensureColumnProperty(this, "nameSQL", () => columnName.escapeSQL);

  String get fullname => _ensureColumnProperty(this, "fullname", () => "${tableName.escapeSQL}.$nameSQL");

  TableProto get tableProto => _getColumnProperty(this, "tableProto");

  set _tableProto(TableProto p) {
    _setColumnProperty(this, "tableProto", p);
  }

  V? get<V>(Object? container) {
    if (container == null) return null;
    return _getModelValue(container, this.columnName);
  }

  void set(Object model, dynamic value) {
    _setModelValue(model, this.columnName, value);
  }

  MapEntry<TableColumn, dynamic> operator >>(dynamic value) {
    return MapEntry<TableColumn, dynamic>(this, proto.encode(value));
  }
}

final Map<Enum, AnyMap> _columnPropMap = {};

V? _getColumnProperty<V>(TableColumn column, String key) {
  return _columnPropMap[column]?[key];
}

void _setColumnProperty(TableColumn column, String key, dynamic value) {
  AnyMap? map = _columnPropMap[column];
  if (map != null) {
    if (value == null) {
      map.remove(key);
    } else {
      map[key] = value;
    }
  } else {
    if (value != null) {
      _columnPropMap[column] = {key: value};
    }
  }
}

V _ensureColumnProperty<V extends Object>(TableColumn column, String key, V Function() onMiss) {
  V? v = _getColumnProperty(column, key);
  if (v != null) return v;
  v = onMiss();
  _setColumnProperty(column, key, v);
  return v;
}
