part of 'postgres.dart';

class JSONB extends ColumnProto {
  const JSONB({
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "JSONB");
}

class JSON extends ColumnProto {
  const JSON({
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "JSON");
}

class UUID extends ColumnProto {
  const UUID({
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "UUID");
}

class BOOLEAN extends ColumnProto {
  const BOOLEAN({
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "BOOLEAN");
}

class TIMESTAMP extends ColumnProto {
  const TIMESTAMP({
    bool zone = false,
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: zone ? "TIMESTAMPZ" : "TIMESTAMP");
}

class TIME extends ColumnProto {
  const TIME({
    bool zone = false,
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: zone ? "TIMEZ" : "TIME");
}

class DATE extends ColumnProto {
  const DATE({
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "DATE");
}

class BLOB extends ColumnProto {
  const BLOB({
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "BYTEA");
}

class VARCHAR extends ColumnProto {
  const VARCHAR({
    required int length,
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "VARCHAR($length)");
}

class CHAR extends ColumnProto {
  const CHAR({
    required int length,
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "CHAR($length)");
}

class TEXT extends ColumnProto {
  const TEXT({
    super.rename,
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

class DOUBLE extends ColumnProto {
  const DOUBLE({
    super.rename,
    super.type = "DOUBLE PRECISION",
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
    required int p,
    required int s,
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.autoInc = 0,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "NUMERIC($p, $s)");
}

class INT64 extends ColumnProto {
  const INT64({
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.autoInc = 0,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: autoInc > 0 ? "BIGSERIAL" : "BIGINT");
}

class INT32 extends ColumnProto {
  const INT32({
    super.rename,
    super.primaryKey = false,
    super.notNull = false,
    super.autoInc = 0,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: autoInc > 0 ? "SERIAL" : "INTEGER");
}
