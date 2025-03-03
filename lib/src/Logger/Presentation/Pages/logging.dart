import 'package:flutter/material.dart';

import '../../Controller/controller.dart';
import '../../Utils/logger_appbar.dart';
import '../Widgets/log_listener_widget.dart';

class LoggingPage extends StatefulWidget {
  const LoggingPage({super.key});

  @override
  State<LoggingPage> createState() => _LoggingPageState();
}

class _LoggingPageState extends State<LoggingPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LoggerAppBar(
        title: 'Logging',
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    logger().clear();
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  ),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: LogListenerWidget(
                    builder: (context, data) {
                      return Text('NEW LOGS:\n${data.logs}');
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
