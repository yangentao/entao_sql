import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';

extension StreamMultiCopy<T> on Stream<T> {
  Stream<T> multiCopy({VoidCallback? onDone, Function? onError}) {
    VoidCallback? doneCallback = onDone;
    Function? errorCallback = onError;
    Set<MultiStreamController<T>> controllerSet = {};
    List<T> buffer = [];
    this.listen((v) {
      buffer.add(v);
      for (final a in controllerSet) {
        a.add(v);
      }
    }, onDone: () {
      for (final a in controllerSet) {
        a.close();
      }
      buffer.clear();
      controllerSet.clear();
      doneCallback?.call();
    }, onError: (e, st) {
      for (final a in controllerSet) {
        a.addError(e, st);
      }
      errorCallback?.call(e, st);
    });

    return Stream<T>.multi((m) {
      controllerSet.add(m);
      for (final v in buffer) {
        m.add(v);
      }
    });
  }
}

void main() async {
  Stream<int> st = gen(10);
  Stream<int> ss = st.multiCopy(onDone: () => print("Done!"));

  ss.listen((v) => print("listen1 $v"));
  ss.listen((v) => print("listen2 $v"));
  ss.last.then((v) => print("last: $v"));
  await Future.delayed(Duration(seconds: 3));
}

Stream<int> gen(int maxValue) async* {
  int i = 0;
  while (i < maxValue) {
    yield i;
    i += 1;
  }
}
