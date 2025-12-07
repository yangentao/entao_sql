import 'dart:async';

import 'package:println/println.dart';

void main() async {
  Stream<int> s = Stream.fromIterable([1, 2, 3]);
  println("multi? ", s.isBroadcast);
  s.length.then((n) {
    println("length: ", n);
  });
  s.last.then((v){
    println("last: ",v);
  });
  s.listen((v) {
    println("value: ", v);
  });
}

Future<void> hello() async {
  println("hello async ");
}

void blank() {
  println("hello");
}
