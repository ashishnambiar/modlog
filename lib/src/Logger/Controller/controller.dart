import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

part 'logger_state.dart';

final logger = dLog(
  label: 'Global',
  onChange: (LogInfo logs) {
    GetIt.I<LoggerController>()._logging(logs);
  },
);

class LoggerController {
  final StreamController<LoggerState> _loggerController =
      StreamController.broadcast();
  Stream<LoggerState> get loggerStream => _loggerController.stream;
  StreamSink<LoggerState> get _loggerSink => _loggerController.sink;

  LoggerController()
      : _state = LoggerState(
          logs: LogInfo(),
          overlayState: LoggerOverlayClosed(),
          networkLoggerState: const NetworkLoggerState(
            networkLogs: {},
          ),
        ) {
    loggerStream.listen(
      (state) {
        _prev = _state;
        _state = state;
      },
    );
  }

  LoggerState? _prev;
  LoggerState? get prev => _prev;

  LoggerState _state;
  LoggerState get state => _state;

  void _logging(LogInfo buf) {
    _loggerSink.add(
      state.copyWith(logs: buf),
    );
  }

  void openLogger(context) => _loggerSink.add(
        state.copyWith(overlayState: LoggerOverlayOpened(context: context)),
      );
  void closeLogger() => _loggerSink.add(
        state.copyWith(overlayState: LoggerOverlayClosed()),
      );
  void minimizeLogger(BuildContext context) {
    if (state.overlayState case LoggerOverlayClosed()) {
      openLogger(context);
    }
    _loggerSink.add(
      state.copyWith(overlayState: LoggerOverlayMinimized()),
    );
  }

  void clearNetworkLogs() {
    _loggerSink.add(
      state.copyWith(
        networkLoggerState: const NetworkLoggerState(
          networkLogs: {},
        ),
      ),
    );
  }

  void addRequestLog(RequestOptions options) {
    final newRequest = {
      options.extra['id']: const NetworkLoggerData().addRequest(options)
    };
    _loggerSink.add(
      state.copyWith(
        networkLoggerState: state.networkLoggerState.copyWith(
          networkLogs: {
            ...state.networkLoggerState.networkLogs,
            ...newRequest,
          },
        ),
      ),
    );
  }

  void addResultLog({required Response? response, NetworkError? error}) {
    final options = response?.requestOptions;
    final networkLog =
        state.networkLoggerState.networkLogs[options?.extra['id']];
    if (networkLog == null) return;

    final newRequest = {
      options?.extra['id']:
          networkLog.addResult(response: response, error: error)
    };

    _loggerSink.add(
      state.copyWith(
        networkLoggerState: NetworkLoggerState(
          networkLogs: {
            ...state.networkLoggerState.networkLogs,
            ...newRequest,
          },
        ),
      ),
    );
  }

  void filterLogs({
    MethodFilter? methodFilter,
    StatusFilter? statusFilter,
  }) {
    _loggerSink.add(
      state.copyWith(
        networkLoggerState: state.networkLoggerState.copyWith(
          methodFilter: methodFilter,
          statusFilter: statusFilter,
        ),
      ),
    );
  }

  void clearFilter() => filterLogs(
        methodFilter: MethodFilter.none,
        statusFilter: StatusFilter.none,
      );

  void clearMethodFilter() => filterLogs(
        methodFilter: MethodFilter.none,
      );

  void clearStatusFilter() => filterLogs(
        statusFilter: StatusFilter.none,
      );
}

extension LoggerControllerExt on LoggerController {
  Stream<NetworkLoggerState> get networkLoggerStream => loggerStream.transform(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            if (prev?.networkLoggerState == data.networkLoggerState) return;
            sink.add(data.networkLoggerState);
          },
        ),
      );
}

class LogInfo extends StringBuffer {
  String get logs => toString();
  Iterable<String> toIterable() =>
      toString().split('\n').where((element) => element.isNotEmpty);
  List<String> toList() => toIterable().toList();
  String? get last => toIterable().isEmpty ? null : toIterable().last;
  @override
  void clear() {
    super.clear();
    GetIt.I<LoggerController>()._logging(logger());
  }
}

LogsCallback dLog({String? label, void Function(LogInfo)? onChange}) {
  final logs = LogInfo();
  final topLevelLabel = label;

  return ({String? message, String? label}) {
    final labelHandler = label ?? topLevelLabel;
    final currentL = logs.toString();
    if (message != null) {
      if (labelHandler != null) {
        logs.write('[$labelHandler] ');
      }
      logs
        ..write("(${DateFormat("HH:mm:ss.SSS").format(DateTime.now())}): ")
        ..write(message)
        ..write('\n');
    }
    if (onChange != null && currentL != logs.toString()) {
      onChange(logs);
    }
    return logs;
  };
}

typedef LogsCallback = LogInfo Function({String? message, String? label});

extension LogsCallbackExt on LogsCallback {
  void initialize() {
    GetIt.I.registerSingleton<LoggerController>(LoggerController());
  }
}
