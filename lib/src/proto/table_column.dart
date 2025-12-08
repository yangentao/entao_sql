part of '../sql.dart';

/// don't use 'name', use 'columnName',  enum's name maybe renamed.
mixin TableColumn<T extends Enum> on Enum {
  Type get tableType => T;

  String get tableName => exGetOrPut("tableName", () {
        String a = "$T";
        if (a == "Object") errorSQL("TableColumn MUST has a generic type parameter. forexample:  enum Person with TableColumn<Person> ");
        return a;
      });

  List<T> get columns;

  ColumnProto get proto;

  String get columnName => exGetOrPut("nameColumn", () => (proto.rename ?? this.name));

  String get nameSQL => exGetOrPut("nameSQL", () => columnName.escapeSQL);

  String get fullname => exGetOrPut("fullname", () => "${tableName.escapeSQL}.$nameSQL");

  TableProto get tableProto => exGet("tableProto");

  set tableProto(TableProto p) {
    exSet("tableProto", p);
  }

  Map<String, dynamic> get _propMap => _columnPropMap.getOrPut(this, () => <String, dynamic>{});

  V exGetOrPut<V>(String key, V Function() onMiss) {
    return _propMap.getOrPut(key, onMiss);
  }

  V? exGet<V>(String key) {
    return _propMap[key];
  }

  void exSet(String key, dynamic value) => _propMap[key] = value;

  V? get<V>(Object? container) {
    if (container == null) return null;
    return _getModelValue(container, this.columnName);
  }

  void set(Object model, dynamic value) {
    _setModelValue(model, this.columnName, value);
  }

  MapEntry<TableColumn<T>, dynamic> operator >>(dynamic value) {
    return MapEntry<TableColumn<T>, dynamic>(this, value);
  }

  String defineField(bool multiKey, DBType dbType) {
    List<String> ls = [nameSQL];
    ls << proto.type;
    if (proto.primaryKey && !multiKey) {
      ls << "PRIMARY KEY";
      if (proto.autoInc) {
        ls << "AUTOINCREMENT";
      }
    }
    if (!proto.primaryKey && !multiKey) {
      if (proto.unique) {
        ls << "UNIQUE";
      }
      if (proto.notNull) {
        ls << "NOT NULL";
      }
    }
    if (proto.defaultValue != null && proto.defaultValue!.isNotEmpty) {
      ls << "DEFAULT ${proto.defaultValue}";
    }
    if (proto.check != null && proto.check!.isNotEmpty) {
      ls << "CHECK (${proto.check})";
    }
    if (proto.extras.notBlank) {
      ls << proto.extras!;
    }
    return ls.join(" ");
  }
}

final Map<Enum, Map<String, dynamic>> _columnPropMap = {};
