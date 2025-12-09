part of 'sqlite.dart';

enum Configs with TableColumn<Configs> {
  name(TEXT(primaryKey: true)),
  nValue(BIGINT()),
  fValue(DOUBLE()),
  sValue(TEXT());

  const Configs(this.proto);

  @override
  final ColumnProto proto;

  @override
  List<Configs> get columns => Configs.values;
}

class MConfigs extends TableModel<Configs> {
  MConfigs(super.model);

  String get name => Configs.name.get(this);

  set name(String value) => Configs.name.set(this, value);

  String? get sValue => Configs.sValue.get(this);

  set sValue(String? value) => Configs.sValue.set(this, value);

  int? get nValue => Configs.nValue.get(this);

  set nValue(int? value) => Configs.nValue.set(this, value);

  double? get fValue => Configs.fValue.get(this);

  set fValue(double? value) => Configs.fValue.set(this, value);

  static void remove(String name) async {
    await table.deleteBy(key: name);
  }

  static void putString(String name, String value) async {
    await table.upsert(values: [Configs.name >> name, Configs.sValue >> value]);
  }

  static void putInt(String name, int value) async {
    await table.upsert(values: [Configs.name >> name, Configs.nValue >> value]);
  }

  static void putDouble(String name, double value) async {
    await table.upsert(values: [Configs.name >> name, Configs.fValue >> value]);
  }

  static Future<String?> getString(String name) async {
    return await table.oneValue(column: Configs.sValue, where: Configs.name.EQ(name));
  }

  static Future<int?> getInt(String name) async {
    return await table.oneValue(column: Configs.nValue, where: Configs.name.EQ(name));
  }

  static Future<double?> getDouble(String name) async {
    return await table.oneValue(column: Configs.fValue, where: Configs.name.EQ(name));
  }

  static final table = TableOf(MConfigs.new);
}
