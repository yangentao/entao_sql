part of '../sql.dart';

class ColumnProto {
  final String? name;
  final String type;
  final bool primaryKey;
  final int autoInc; //AUTOINCREMENT
  final bool unique;
  final bool notNull;
  final bool index;
  final String? defaultValue;
  final String? check;
  final String? uniqueName;
  final String? extras;

  const ColumnProto({
    this.name,
    required this.type,
    this.primaryKey = false,
    this.notNull = false,
    this.autoInc = 0,
    this.unique = false,
    this.index = false,
    this.check,
    this.uniqueName,
    this.defaultValue,
    this.extras,
  });

  /// decode from database value to dart value
  Object? decode(Object? value) => value;

  /// encode datr value to database value
  Object? encode(Object? value) => value;
}
