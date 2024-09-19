import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../Controller/controller.dart';

class LogListenerWidget extends StatefulWidget {
  const LogListenerWidget({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, LogInfo data) builder;

  @override
  State<LogListenerWidget> createState() => _LogListenerWidgetState();
}

class _LogListenerWidgetState extends State<LogListenerWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoggerState>(
      stream: GetIt.I<LoggerController>().loggerStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.logs;
        if (snapshot.hasData && data != null) {
          return widget.builder(context, logger());
        }
        if (logger().isNotEmpty) {
          return widget.builder(context, logger());
        }
        return const Text('No Data');
      },
    );
  }
}
