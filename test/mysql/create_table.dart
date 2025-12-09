import 'package:entao_sql/mysql.dart';
import 'package:mysql1_ext/mysql1_ext.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

Future<SQLExecutor> _createExecutor() async {
  final setting = ConnectionSettings(host: "localhost", port: 3306, user: "test", password: "test", db: "test", useSSL: false, timeout: Duration(seconds: 10));
  final c = await MySqlConnection.connect(setting);
  return MySqlConnectionExecutor(c, database: "test", migrator: MySQLMigrator("test"));
}

enum Person with TableColumn<Person> {
  id(BIGINT(primaryKey: true, autoInc: 1000)),
  name(VARCHAR(length: 128)),
  nValue(BIGINT()),
  fValue(DOUBLE()),
  sValue(TEXT());

  const Person(this.proto);

  @override
  final ColumnProto proto;

  @override
  List<Person> get columns => Person.values;
}

void main() {
  test("auto inc", () async {
    final ex = await _createExecutor();
    ex.rawQuery("DROP TABLE Person ");
    await ex.register(Person.values, migrate: true);
    RowData? row = await ex.insert(Person, values: [Person.name >> "entao", Person.nValue >> 33]);
    println(row);
    await ex.dump(Person);

    expect(row?.get("id"), 1000);
  });
}
