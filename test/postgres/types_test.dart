import 'package:entao_sql/postgres.dart';
import 'package:test/test.dart';

void main()  async {
  test("array", () {
    expect(ARRAY().type, "ARRAY");
    expect(ARRAY<bool>().type, "BOOL[]");
    expect(ARRAY<BOOLEAN>().type, "BOOL[]");
    expect(ARRAY<int>().type, "BIGINT[]");
    expect(ARRAY<BIGINT>().type, "BIGINT[]");
    expect(ARRAY<double>().type, "FLOAT[]");
    expect(ARRAY<DOUBLE>().type, "FLOAT[]");
    expect(ARRAY<String>().type, "TEXT[]");
    expect(ARRAY<TEXT>().type, "TEXT[]");
    expect(ARRAY<INT32>().type, "INTEGER[]");
    expect(ARRAY<FLOAT32>().type, "REAL[]");
    expect(ARRAY<BLOB>().type, "BYTEA[]");
    expect(ARRAY<TIME>().type, "TIME[]");
    expect(ARRAY<TIMETZ>().type, "TIMETZ[]");
    expect(ARRAY<TIMESTAMP>().type, "TIMESTAMP[]");
    expect(ARRAY<TIMESTAMPTZ>().type, "TIMESTAMPTZ[]");
  });
}
