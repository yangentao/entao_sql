part of 'mysql.dart';

class INTEGER extends ColumnProto {
  const INTEGER({
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
