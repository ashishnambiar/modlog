import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../Controller/controller.dart';
import '../../Utils/debouncer.dart';

class LogTriggerWidget extends StatefulWidget {
  const LogTriggerWidget({
    super.key,
    required this.child,
    this.isAvailable = true,
    this.maxCount = 5,
  });
  final Widget child;
  final int maxCount;
  final bool isAvailable;

  @override
  State<LogTriggerWidget> createState() => _LogTriggerWidgetState();
}

class _LogTriggerWidgetState extends State<LogTriggerWidget> {
  int _count = 0;

  final _debouncer = Debouncer(
    debounceInterval: const Duration(milliseconds: 500),
  );

  final loggerController = GetIt.I<LoggerController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        _debouncer.call(
          () {
            _count = 0;
          },
          onInterrupted: () {
            if (!widget.isAvailable) return;
            _count++;
            if (_count >= widget.maxCount) {
              loggerController.openLogger(context);
            }
          },
        );
      },
      child: widget.child,
    );
  }
}
