part of 'sqlite.dart';

/// https://sqlite.org/datatype3.html

// Enum,  Methods can't be invoked in constant expressions.

class INT64 extends ColumnProto {
  const INT64({
    super.rename,
    super.type = "INTEGER",
    super.primaryKey = false,
    super.notNull = false,
    super.autoInc = 0,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  });
}

class REAL64 extends ColumnProto {
  const REAL64({
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
