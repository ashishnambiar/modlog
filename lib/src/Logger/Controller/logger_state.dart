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
  final MethodFilter methodFilter;
  final StatusFilter statusFilter;
  const NetworkLoggerState({
    required this.networkLogs,
    this.methodFilter = MethodFilter.none,
    this.statusFilter = StatusFilter.none,
  });

  int get count => filteredLogs.length;

  Map<String, NetworkLoggerData> get filteredLogs {
    final logs = <String, NetworkLoggerData>{};
    if (methodFilter == MethodFilter.none && //
        statusFilter == StatusFilter.none) {
      return networkLogs;
    }

    for (final e in networkLogs.entries) {
      if (methodFilter != MethodFilter.none) {
        if (e.value.request?.method.toLowerCase() !=
            methodFilter.name.toLowerCase()) {
          continue;
        }
      }
      if (statusFilter != StatusFilter.none) {
        if (statusFilter !=
            StatusFilter.fromInt(
              e.value.result?.response?.statusCode ?? 0,
            )) {
          continue;
        }
      }
      logs.addEntries([e]);
    }
    return logs;
  }

  NetworkLoggerState copyWith({
    Map<String, NetworkLoggerData>? networkLogs,
    MethodFilter? methodFilter,
    StatusFilter? statusFilter,
  }) =>
      NetworkLoggerState(
        networkLogs: networkLogs ?? this.networkLogs,
        methodFilter: methodFilter ?? this.methodFilter,
        statusFilter: statusFilter ?? this.statusFilter,
      );

  @override
  List<Object?> get props => [
        networkLogs,
        methodFilter,
        statusFilter,
      ];
}

sealed class NetLogFilter extends Equatable {
  const NetLogFilter();

  @override
  List<Object?> get props => [];
}

enum MethodFilter {
  get,
  post,
  put,
  delete,
  patch,
  head,
  options,
  trace,

  none,
  ;

  static List<MethodFilter> get visible =>
      values.where((e) => e != none).toList();
}

enum StatusFilter {
  informational(100, 199),
  successful(200, 299),
  redirection(300, 399),
  clientError(400, 499),
  serverError(500, 599),

  none(0, 0),
  ;

  final int max;
  final int min;
  const StatusFilter(
    this.max,
    this.min,
  );

  static List<StatusFilter> get visible =>
      values.where((e) => e != none).toList();

  static StatusFilter fromInt(int value) {
    switch (value) {
      case >= 100 && <= 199:
        return informational;
      case >= 200 && <= 299:
        return successful;
      case >= 300 && <= 399:
        return redirection;
      case >= 400 && <= 499:
        return clientError;
      case >= 500 && <= 599:
        return serverError;
      default:
        return none;
    }
  }
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
