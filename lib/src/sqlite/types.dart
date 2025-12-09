part of 'sqlite.dart';

/// https://sqlite.org/datatype3.html

class JSONB extends ColumnProto {
  const JSONB({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class JSON extends ColumnProto {
  const JSON({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class UUID extends ColumnProto {
  const UUID({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class BOOLEAN extends ColumnProto {
  const BOOLEAN({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "INTEGER");
}

class TIMESTAMP extends ColumnProto {
  const TIMESTAMP({
    int? precision,
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class TIMESTAMPTZ extends ColumnProto {
  const TIMESTAMPTZ({
    int? precision,
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class TIME extends ColumnProto {
  const TIME({
    int? precision,
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class TIMETZ extends ColumnProto {
  const TIMETZ({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class DATE extends ColumnProto {
  const DATE({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class BLOB extends ColumnProto {
  const BLOB({
    bool longBlob = false,
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "BLOB");
}

class VARCHAR extends ColumnProto {
  const VARCHAR({
    required int length,
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class CHAR extends ColumnProto {
  const CHAR({
    required int length,
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class TEXT extends ColumnProto {
  const TEXT({
    bool longText = false,
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}

class FLOAT32 extends ColumnProto {
  const FLOAT32({
    super.name,
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

class DOUBLE extends ColumnProto {
  const DOUBLE({
    super.name,
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
    int? p,
    int? s,
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.autoInc = 0,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "NUMERIC");
}

class BIGINT extends ColumnProto {
  const BIGINT({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.autoInc = 0,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "INTEGER");
}

class INT32 extends ColumnProto {
  const INT32({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.autoInc = 0,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "INTEGER");
}

class ARRAY<T extends Object> extends ColumnProto {
  const ARRAY({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TEXT");
}
