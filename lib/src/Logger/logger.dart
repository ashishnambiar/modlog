import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'Controller/controller.dart';
import 'Presentation/Pages/logging_launch_page.dart';

class LoggerScope extends StatefulWidget {
  const LoggerScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<LoggerScope> createState() => _LoggerWidgetState();
}

class _LoggerWidgetState extends State<LoggerScope> {
  @override
  void initState() {
    logger.initialize();
    _sub = loggerController.loggerStream.listen((state) {
      switch (state.overlayState) {
        case LoggerOverlayOpened(overlayState: final overlayState):
          if (overlayState == null) return;
          _openDebug(overlayState);
        case LoggerOverlayClosed():
          _closeDebug();
        case LoggerOverlayMinimized():
      }
    });

    super.initState();
  }

  void _openDebug(OverlayState overlayState) {
    if (_entry != null && _entry!.mounted) return;
    _entry = _overlayWidget();
    overlayState.insert(_entry!);
  }

  void _closeDebug() {
    _entry?.remove();
    _entry = null;
  }

  OverlayEntry? _entry;

  OverlayEntry _overlayWidget() {
    return OverlayEntry(
      builder: (context) => StreamBuilder<LoggerOverlayState>(
        stream: loggerController //
            .loggerStream
            .transform(
          StreamTransformer<LoggerState, LoggerOverlayState>.fromHandlers(
            handleData: (data, sink) {
              if (data.overlayState == loggerController.prev?.overlayState) {
                return;
              }
              sink.add(data.overlayState);
            },
          ),
        ),
        builder: (context, snapshot) {
          var minimized = false;
          if (snapshot.data case LoggerOverlayMinimized()) minimized = true;
          return LoggerLaunchPage(minimized: minimized);
        },
      ),
    );
  }

  late final StreamSubscription<LoggerState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  late final loggerController = GetIt.I<LoggerController>();

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
