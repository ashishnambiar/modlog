import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../Controller/controller.dart';
import '../../Utils/logger_appbar.dart';
import '../../Utils/netowork_interceptor.dart';
import 'network_details_page.dart';

class NetworkInterceptorPage extends StatefulWidget {
  const NetworkInterceptorPage({super.key});

  @override
  State<NetworkInterceptorPage> createState() => _NetworkInterceptorPageState();
}

class _NetworkInterceptorPageState extends State<NetworkInterceptorPage> {
  final loggerController = GetIt.I<LoggerController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoggerAppBar(
        title: 'Network ' * 10,
        actions: [
          IconButton(
            onPressed: () {
              loggerController.clearNetworkLogs();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: StreamBuilder<NetworkLoggerState>(
        stream: loggerController.loggerStream.transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              if (loggerController.prev?.networkLoggerState ==
                  data.networkLoggerState) return;
              sink.add(data.networkLoggerState);
            },
          ),
        ),
        builder: (context, snapshot) {
          return Scrollbar(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final log = loggerController
                    .state.networkLoggerState.networkLogs.values
                    .toList()[index];
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NetworkDetailsPage(
                          networkLog: log,
                        ),
                      ),
                    );
                  },
                  subtitle: Text(log.request?.uri.withoutQuery ?? 'null'),
                  title: Text(
                      '${log.request?.method} ${log.result?.response?.statusCode ?? 'null'}'),
                  tileColor: index % 2 == 0 //
                      ? Colors.amber[100]
                      : Colors.transparent,
                );
              },
              itemCount: loggerController.state.networkLoggerState.count,
            ),
          );
        },
      ),
    );
  }
}
