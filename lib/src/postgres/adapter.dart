import 'dart:async';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:postgres/postgres.dart' hide Type;

import '../sql.dart';

// final _endpoint = Endpoint(host: 'localhost', database: 'test', username: 'test', password: 'test');
// final poolPG = Pool.withEndpoints([_endpoint], settings: PoolSettings(sslMode: SslMode.disable));

class PostgresExecutor<T> extends SQLExecutor {
  final SessionExecutor executor;
  final Duration? timeout;
  final QueryMode? queryMode;
  final TransactionSettings? transactionSettings;
  Session? _session;

  PostgresExecutor(this.executor, {this.timeout, this.queryMode, this.transactionSettings});

  @override
  Future<Stream<RowData>> queryStream(String sql, {AnyList? parameters}) async {
    if (_session case Session se) {
      Statement st = await se.prepare(sql);
      Stream<RowData> s = st.bind(parameters).map((r) => RowData(r, meta: r.schema.meta));
      StreamController<RowData> controller = StreamController(onCancel: () => st.dispose());
      s.listen(controller.add, onDone: () {
        controller.close();
        st.dispose();
      }, onError: controller.addError);
      return controller.stream;
    } else {
      return executor.run((se) async {
        Statement st = await se.prepare(sql);
        Stream<RowData> s = st.bind(parameters).map((r) => RowData(r, meta: r.schema.meta));
        StreamController<RowData> controller = StreamController(onCancel: () => st.dispose());
        s.listen(controller.add, onDone: () {
          controller.close();
          st.dispose();
        }, onError: controller.addError);
        return controller.stream;
      });
    }
  }

  @override
  Future<QueryResult> rawQuery(String sql, {AnyList? parameters}) async {
    if (_session case Session se) {
      Result r = await se.execute(sql, parameters: parameters, timeout: timeout, queryMode: queryMode);
      return QueryResult(r, meta: r.meta, rawResult: r);
    } else {
      return executor.run((se) async {
        Result r = await se.execute(sql, parameters: parameters, timeout: timeout, queryMode: queryMode);
        return QueryResult(r, meta: r.meta, rawResult: r);
      }, settings: SessionSettings(queryTimeout: timeout, queryMode: queryMode));
    }
  }

  @override
  Future<void> execute(String sql, {AnyList? parameters}) async {
    if (_session case Session se) {
      await se.execute(sql, parameters: parameters, timeout: timeout, ignoreRows: true, queryMode: queryMode);
    } else {
      return executor.run((se) async {
        await se.execute(sql, parameters: parameters, timeout: timeout, ignoreRows: true, queryMode: queryMode);
      }, settings: SessionSettings(queryTimeout: timeout, queryMode: queryMode));
    }
  }

  @override
  Future<void> transaction(FutureOr<void> Function() callback) async {
    executor.runTx((session) async {
      _session = session;
      try {
        if (callback is FutureCallback) {
          await callback();
        } else {
          callback();
        }
      } finally {
        _session = null;
      }
    }, settings: transactionSettings);
  }
}

extension ResultMetaPGExt on Result {
  ResultMeta get meta => this.schema.meta;
}

extension ResultMetaResultSchemaExt on ResultSchema {
  ResultMeta get meta => ResultMeta(this.columns.mapIndex((i, e) => ColumnMeta(label: e.columnName ?? "[$i]", typeId: e.typeOid)));
}
