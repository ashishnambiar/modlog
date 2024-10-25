import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../Controller/controller.dart';

class NetworkRequestInterceptor extends Interceptor {
  final loggerController = GetIt.I<LoggerController>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra.addAll({'id': '${DateTime.now().microsecondsSinceEpoch}'});

    GetIt.I<LoggerController>().addRequestLog(options);
    super.onRequest(options, handler);
  }
}

class NetworkResponseInterceptor extends Interceptor {
  final loggerController = GetIt.I<LoggerController>();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    GetIt.I<LoggerController>().addResultLog(response: response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    GetIt.I<LoggerController>().addResultLog(
      response: err.response,
      error: err.networkError,
    );

    super.onError(err, handler);
  }
}

extension RequestOptionsExtension on RequestOptions {
  Map<String, dynamic> get tryJson {
    if (data.runtimeType == String) {
      try {
        return jsonDecode(data);
      } catch (e) {
        return {};
      }
    }
    try {
      jsonEncode(data);
      return data;
    } catch (e) {
      return {};
    }
  }

  String get cURL {
    final buffer = StringBuffer();
    buffer.write("curl --location --request $method '$uri'");

    for (final e in headers.entries) {
      buffer
        ..write(' \\\n')
        ..write("--header '${e.key}: ${e.value}'");
    }

    if (tryJson.isNotEmpty) {
      buffer
        ..write(' \\\n')
        ..write("--data-raw '${tryJson.toString()}'");
    }

    return buffer.toString();
  }
}

extension UriExtension on Uri {
  String get withoutQuery => origin + path;
}
