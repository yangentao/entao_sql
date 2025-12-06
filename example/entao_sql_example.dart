import 'dart:async';

import 'package:entao_sql/sqlite.dart';
import 'package:println/println.dart';

void main() async {
  FutureOrCallback a = blank;
  if (a case FutureCallback b) {
    println("async");
    await b();
  } else {
    println("sync");
    a();
  }
}

Future<void> hello() async {
  println("hello async ");
}

void blank() {
  println("hello");
}
