import 'package:entao_sql/postgres.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

Future<SQLExecutor> _createExecutor() async {
  final endpoint = Endpoint(host: 'localhost', database: 'test', username: 'test', password: 'test');
  final c = await Connection.open(endpoint, settings: ConnectionSettings(sslMode: SslMode.disable));
  return PgConnectionExecutor(c, migrator: PgMigrator());
  // return Pool.withEndpoints([endpoint], settings: PoolSettings(sslMode: SslMode.disable));
}

enum Person with TableColumn<Person> {
  name(TEXT(primaryKey: true)),
  nValue(LONG()),
  fValue(DOUBLE()),
  sValue(TEXT());

  const Person(this.proto);

  @override
  final ColumnProto proto;

  @override
  List<Person> get columns => Person.values;
}

void main() {
  test("exist", () async {
    final ex = await _createExecutor();
    final r = await ex.rawQuery(r"SELECT 1 FROM pg_tables WHERE schemaname=? AND tablename=?", ['public', 'person']);
    r.dump();
  });

  test("b", () async {
    final ex = await _createExecutor();
    await ex.register(Person.values, migrate: true);
    await ex.insert(Person, values: [Person.name >> "entao", Person.nValue >> 33]);
    await ex.dump(Person);
  });

  test("a", () async {
    final ex = await _createExecutor();
    final r = await ex.query([], from: "test");
    r.dump();
  });

  test("array", () {
    expect(ARRAY().type, "ARRAY");
    expect(ARRAY<bool>().type, "BOOL[]");
    expect(ARRAY<BOOLEAN>().type, "BOOL[]");
    expect(ARRAY<int>().type, "BIGINT[]");
    expect(ARRAY<LONG>().type, "BIGINT[]");
    expect(ARRAY<double>().type, "FLOAT[]");
    expect(ARRAY<DOUBLE>().type, "FLOAT[]");
    expect(ARRAY<String>().type, "TEXT[]");
    expect(ARRAY<TEXT>().type, "TEXT[]");
    expect(ARRAY<INT32>().type, "INTEGER[]");
    expect(ARRAY<FLOAT32>().type, "REAL[]");
    expect(ARRAY<BLOB>().type, "BYTEA[]");
    expect(ARRAY<TIME>().type, "TIME[]");
    expect(ARRAY<TIMEZ>().type, "TIMEZ[]");
  });
}
