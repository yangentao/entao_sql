import 'package:println/println.dart';

void main() async {
  // SQliteExecutor e = SQliteExecutor(LiteSQL.openMemory());
  // QueryResult r = await e.query([], from: "sqlite_master", limit: 1);
  // r.dump();
  Set<Object> s = {};
  s.add(A.a);
  s.add(B.a);
  println(s.contains(A.a));
  println(s.contains(B.a));
}

enum A {
  a,
  b,
  c;
}

enum B {
  a,
  b,
  c;
}
