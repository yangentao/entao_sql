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
  MySQLExecutor e = await MySQLExecutor.create(endpoint: endpoint, database: "test");
  OnMigratorMySQL mig = OnMigratorMySQL(database: "test");
  QueryResult r = await e.rawQuery("DROP TABLE IF EXISTS test");
  await e.register(Test.values, migrator: mig);
  RowData? row = await e.insert(Test, values: [Test.name >> "entao", Test.nValue >> 33]);
  println(row);
  await e.dump(Test);
  // expect(row?.get("id"), 1000);
}
