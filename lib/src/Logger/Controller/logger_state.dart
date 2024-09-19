part of 'controller.dart';

class LoggerState extends Equatable {
  const LoggerState({
    required this.logs,
    required this.overlayState,
    required this.networkLoggerState,
  });

  final LogInfo logs;
  final LoggerOverlayState overlayState;
  final NetworkLoggerState networkLoggerState;

  LoggerState copyWith({
    LogInfo? logs,
    LoggerOverlayState? overlayState,
    NetworkLoggerState? networkLoggerState,
  }) =>
      LoggerState(
        logs: logs ?? this.logs,
        overlayState: overlayState ?? this.overlayState,
        networkLoggerState: networkLoggerState ?? this.networkLoggerState,
      );

  @override
  List<Object?> get props => [
        logs,
        overlayState,
        networkLoggerState,
      ];
}

/*
 _                                   ___                 _             
| |    ___   __ _  __ _  ___ _ __   / _ \__   _____ _ __| | __ _ _   _ 
| |   / _ \ / _` |/ _` |/ _ \ '__| | | | \ \ / / _ \ '__| |/ _` | | | |
| |__| (_) | (_| | (_| |  __/ |    | |_| |\ V /  __/ |  | | (_| | |_| |
|_____\___/ \__, |\__, |\___|_|     \___/  \_/ \___|_|  |_|\__,_|\__, |
            |___/ |___/                                          |___/ 
 ____  _        _       
/ ___|| |_ __ _| |_ ___ 
\___ \| __/ _` | __/ _ \
 ___) | || (_| | ||  __/
|____/ \__\__,_|\__\___|
*/

sealed class LoggerOverlayState extends Equatable {
  const LoggerOverlayState();
  @override
  List<Object?> get props => [];
}

final class LoggerOverlayClosed extends LoggerOverlayState {}

final class LoggerOverlayMinimized extends LoggerOverlayState {}

final class LoggerOverlayOpened extends LoggerOverlayState {
  const LoggerOverlayOpened({required BuildContext context})
      : _context = context;
  final BuildContext _context;

  OverlayState? get overlayState {
    if (!_context.mounted) return null;
    return Overlay.of(_context);
  }

  @override
  List<Object?> get props => [
        _context,
      ];
}

/*
 _   _      _                      _      _                                
| \ | | ___| |___      _____  _ __| | __ | |    ___   __ _  __ _  ___ _ __ 
|  \| |/ _ \ __\ \ /\ / / _ \| '__| |/ / | |   / _ \ / _` |/ _` |/ _ \ '__|
| |\  |  __/ |_ \ V  V / (_) | |  |   <  | |__| (_) | (_| | (_| |  __/ |   
|_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\ |_____\___/ \__, |\__, |\___|_|   
                                                     |___/ |___/           
*/

final class NetworkLoggerState extends Equatable {
  final Map<String, NetworkLoggerData> networkLogs;
  final NetLogFilter? filter;
  const NetworkLoggerState({
    required this.networkLogs,
    this.filter,
  });

  int get count => filteredLogs.length;

  Map<String, NetworkLoggerData> get filteredLogs {
    final logs = <String, NetworkLoggerData>{};
    for (final e in networkLogs.entries) {
      switch (filter) {
        case MethodFilter(method: final method):
          if (e.value.request?.method.toLowerCase() ==
              method.name.toLowerCase()) {
            logs.addEntries([e]);
          }
        case StatusFilter():
        case null:
          return networkLogs;
      }
    }
    return logs;
  }

  NetworkLoggerState copyWith({
    Map<String, NetworkLoggerData>? networkLogs,
    NetLogFilter? filter,
  }) =>
      NetworkLoggerState(
        networkLogs: networkLogs ?? this.networkLogs,
        filter: filter ?? this.filter,
      );

  NetworkLoggerState clearFilter() => NetworkLoggerState(
        networkLogs: networkLogs,
        filter: null,
      );

  @override
  List<Object?> get props => [
        networkLogs,
        filter,
      ];
}

sealed class NetLogFilter extends Equatable {
  const NetLogFilter();

  @override
  List<Object?> get props => [];
}

enum MethodType {
  get,
  post,
  put,
  delete,
  patch,
  head,
  options,
  trace,
}

class MethodFilter extends NetLogFilter {
  const MethodFilter(this.method);
  final MethodType method;

  @override
  List<Object?> get props => [method];
}

enum StatusType {
  informational(100, 199),
  successful(200, 299),
  redirection(300, 399),
  clientError(400, 499),
  serverError(500, 599);

  final int max;
  final int min;
  const StatusType(
    this.max,
    this.min,
  );
}

class StatusFilter extends NetLogFilter {
  const StatusFilter(this.status);
  final StatusType status;

  @override
  List<Object?> get props => [status];
}

class NetworkLoggerData extends Equatable {
  const NetworkLoggerData({
    this.startTime,
    this.endTime,
    this.request,
    this.result,
  });
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final RequestOptions? request;
  final ({Response? response, NetworkError? error})? result;

  NetworkLoggerData copyWith({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    RequestOptions? request,
    ({Response? response, NetworkError? error})? result,
  }) =>
      NetworkLoggerData(
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        request: request ?? this.request,
        result: result ?? this.result,
      );

  NetworkLoggerData addRequest(
    RequestOptions options,
  ) =>
      copyWith(
        request: options,
        startTime: TimeOfDay.now(),
      );

  NetworkLoggerData addResult(
      {required Response? response, NetworkError? error}) {
    assert(response == null || error == null);
    return copyWith(
      endTime: TimeOfDay.now(),
      result: (response: response, error: error),
    );
  }

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        request,
        result,
      ];
}

extension DioExceptionExt on DioException {
  NetworkError get networkError => NetworkError(
        type: type,
        error: error,
        stackTrace: stackTrace,
        message: message,
      );
}

class NetworkError extends Equatable {
  const NetworkError({
    required this.type,
    required this.error,
    required this.stackTrace,
    required this.message,
  });

  final DioExceptionType type;
  final Object? error;
  final StackTrace stackTrace;
  final String? message;

  @override
  List<Object?> get props => [
        type,
        error,
        stackTrace,
        message,
      ];
}
