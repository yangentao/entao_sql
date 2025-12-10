import 'package:entao_sql/postgres.dart';
import 'package:postgres/postgres.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

Future<TranscationalExecutor> _createExecutor() async {
  final endpoint = Endpoint(host: 'localhost', database: 'test', username: 'test', password: 'test');
  // final c = await Connection.open(endpoint, settings: ConnectionSettings(sslMode: SslMode.disable));
  // return PgConnectionExecutor(c, migrator: PgMigrator());
  final p = Pool.withEndpoints([endpoint], settings: PoolSettings(sslMode: SslMode.disable));
  return PostgresPoolExecutor(p);
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
}

void main() async {
  test("auto inc", () async {
    final ex = await _createExecutor();
    ex.rawQuery("DROP TABLE Person ");
    await ex.register(Person.values, onMigrate: OnMigratorPostgres());
    RowData? row = await ex.insert(Person, values: [Person.name >> "entao", Person.nValue >> 33]);
    println(row);
    await ex.dump(Person);

    expect(row?.get("id"), 1000);
  });
}
