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
  }) {
    return LoggerState(
      logs: logs ?? this.logs,
      overlayState: overlayState ?? this.overlayState,
      networkLoggerState: networkLoggerState ?? this.networkLoggerState,
    );
  }

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
  const NetworkLoggerState({
    required this.networkLogs,
  });

  int get count => networkLogs.length;

  @override
  List<Object?> get props => [networkLogs];
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
