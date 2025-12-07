import 'dart:async';
import 'dart:ffi' as ffi;

import 'package:entao_dutil/entao_dutil.dart';
import 'package:sqlite3/sqlite3.dart';

import '../sql.dart';
import 'sqlite3_ffi.dart' as xsql;

part 'adapter.dart';
part 'litesql.dart';
part 'pragma.dart';
part 'resultset.dart';

enum InsertOption {
  abort("ABORT"),
  fail("FAIL"),
  ignore("IGNORE"),
  replace("REPLACE"),
  rollback("ROLLBACK");

  const InsertOption(this.conflict);

  final String conflict;
}
