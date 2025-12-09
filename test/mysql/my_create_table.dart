import 'package:entao_sql/mysql.dart';
import 'package:mysql_client_plus/mysql_client_plus.dart';

enum Test with TableColumn<Test> {
  id(BIGINT(primaryKey: true, autoInc: 1000)),
  name(VARCHAR(length: 128)),
  nValue(BIGINT()),
  fValue(DOUBLE()),
  sValue(TEXT());

  const Test(this.proto);

  @override
  final ColumnProto proto;

  @override
  List<Test> get columns => Test.values;
}

void main() async {
  MySQLConnection c = await MySQLConnection.createConnection(host: "localhost", port: 3306, userName: "root", password: "Yet19491001", databaseName: "test");
  await c.connect();
  SQLExecutor e = MySqlConnectionExecutor(c, database: "test");
  QueryResult r = await e.rawQuery("select * from test");
  r.dump();
  await e.register(Test.values, migrate: true);
  // test("auto inc", () async {
  //   final ex = await _createExecutor();
  //   await  ex.rawQuery("DROP TABLE test ");
  //   await ex.register(Test.values, migrate: true);
  //   // RowData? row = await ex.insert(Test, values: [Test.name >> "entao", Test.nValue >> 33]);
  //   // println(row);
  //   // await ex.dump(Test);
  //   // expect(row?.get("id"), 1000);
  // });
}
