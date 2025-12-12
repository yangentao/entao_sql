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

enum Person with TableColumn {
  id(BIGINT(primaryKey: true, autoInc: 1000)),
  info(ARRAY<int>());

  const Person(this.proto);

  @override
  final ColumnProto proto;
}

void main() async {
  test("array", () async {
    final ex = await _createExecutor();
    ex.execute("DROP TABLE Person ");
    await ex.register(Person.values, onMigrate: OnMigratorPostgres(schema: "public"));
    RowData? row = await ex.insert(Person, values: [
      Person.info >> ARRAY_VALUE([1, 2, 3])
    ]);
    println(row);
    await ex.dump(Person);
    expect(row?.get("id"), 1000);
    println(row!.get("info").runtimeType);
    QueryResult r = await ex.query([], from: Person, where: Person.id.EQ(1000));
    expect(r.firstValue("info"), equals([1, 2, 3]));
    r.dump();
  });
}
