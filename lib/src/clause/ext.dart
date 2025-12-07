part of '../sql.dart';

extension StringExpressExt on String {

  Express get express => Express(this);

  String AS(String alias) => "$this AS $alias";

  String get ASC => "${this.escapeSQL} ASC";

  String get DESC => "${this.escapeSQL} DESC";

  Express FILTER(Object express) {
    return Express(this) << "FILTER (WHERE" << express << ")";
  }

  Express OVER(Object express) {
    return Express(this) << "OVER" << express;
  }
}

extension TableColumnExpresExt<T extends TableColumn<T>> on TableColumn<T> {
  String AS(String alias) => "$fullname AS $alias";

  String get ASC => "$fullname ASC";

  String get DESC => "$fullname DESC";
}


