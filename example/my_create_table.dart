import 'package:entao_sql/mysql.dart';
import 'package:println/println.dart';

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

final endpoint = Endpoint(username: "root", password: "Yet19491001");

void main() async {
  println("main");
  MySQLExecutor e = await MySQLExecutor.create(endpoint: endpoint, database: "test");
  println("main 1");
  final r = await e.rawQuery("select * from  test");
  r.dump();
  println("main drop");
  // await e.connection.execute("DROP TABLE test");
  // await e.rawQuery("DROP TABLE test", []);
  println("main 2");
  await e.register(Test.values, migrate: true);
  println("main 3");
  RowData? row = await e.insert(Test, values: [Test.name >> "entao", Test.nValue >> 33]);
  println(row);
  await e.dump(Test);

  // expect(row?.get("id"), 1000);
}
