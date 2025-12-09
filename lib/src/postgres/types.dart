part of 'postgres.dart';

/// RowData? row = await ex.insert(Person, values: [
///       Person.info >> JSONB_VALUE([1, 2, 3])
/// ]);


/// value will been json.encode(value), before send to database
pg.TypedValue JSON_VALUE(dynamic value) => pg.TypedValue(pg.Type.json, value);

/// value will been json.encode(value), before send to database
pg.TypedValue JSONB_VALUE(dynamic value) => pg.TypedValue(pg.Type.jsonb, value);

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
  }) : super(type: "JSONB");
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
  }) : super(type: "JSON");
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
  }) : super(type: "UUID");
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
  }) : super(type: "BOOLEAN");
}

class TIMESTAMP extends ColumnProto {
  const TIMESTAMP({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TIMESTAMP");
}

class TIMESTAMPZ extends ColumnProto {
  const TIMESTAMPZ({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TIMESTAMPZ");
}

class TIME extends ColumnProto {
  const TIME({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TIME");
}

class TIMEZ extends ColumnProto {
  const TIMEZ({
    super.name,
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
    super.extras,
  }) : super(type: "TIMEZ");
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
  }) : super(type: "DATE");
}

class BLOB extends ColumnProto {
  const BLOB({
    super.name,
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
    super.name,
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
    super.name,
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
  }) : super(type: "NUMERIC($p, $s)");
}

class LONG extends ColumnProto {
  const LONG({
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
  }) : super(type: autoInc > 0 ? "BIGSERIAL" : "BIGINT");
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
  }) : super(type: autoInc > 0 ? "SERIAL" : "INTEGER");
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
  }) : super(
            type: T == Object
                ? "ARRAY"
                : (T == int || T == LONG)
                    ? "BIGINT[]"
                    : (T == double || T == DOUBLE)
                        ? "FLOAT[]"
                        : T == num
                            ? "NUMERIC[]"
                            : (T == bool || T == BOOLEAN)
                                ? "BOOL[]"
                                : (T == String || T == TEXT)
                                    ? "TEXT[]"
                                    : T == BLOB
                                        ? "BYTEA[]"
                                        : T == FLOAT32
                                            ? "REAL[]"
                                            : T == INT32
                                                ? "INTEGER[]"
                                                : "$T[]");
}
