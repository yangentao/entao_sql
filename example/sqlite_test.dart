import 'package:entao_sql/sqlite.dart';

void main() async {
  SQliteExecutor e = SQliteExecutor(LiteSQL.openMemory());
  QueryResult r = await e.query([], from: "sqlite_master", limit: 1);
  r.dump();
}
