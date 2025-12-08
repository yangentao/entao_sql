part of '../sql.dart';

class ColumnProto {
  final String? rename;
  final String type;
  final bool primaryKey;
  final bool autoInc; //AUTOINCREMENT
  final bool unique;
  final bool notNull;
  final bool index;
  final String? defaultValue;
  final String? check;
  final String? uniqueName;
  final String? extras;

  const ColumnProto({
    this.rename,
    required this.type,
    this.primaryKey = false,
    this.notNull = false,
    this.autoInc = false,
    this.unique = false,
    this.index = false,
    this.check,
    this.uniqueName,
    this.defaultValue,
    this.extras,
  });
}

/// https://sqlite.org/datatype3.html
class INTEGER extends ColumnProto {
  const INTEGER({
    super.rename,
    super.type = "INTEGER",
    super.primaryKey = false,
    super.notNull = false,
    super.autoInc = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  });
}

class REAL extends ColumnProto {
  const REAL({
    super.rename,
    super.type = "REAL",
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  });
}

class NUMERIC extends ColumnProto {
  const NUMERIC({
    super.rename,
    super.type = "NUMERIC",
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  });
}

class TEXT extends ColumnProto {
  const TEXT({
    super.rename,
    super.type = "TEXT",
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  });
}

class BLOB extends ColumnProto {
  const BLOB({
    super.rename,
    super.type = "BLOB",
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  });
}
