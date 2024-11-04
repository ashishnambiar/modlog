import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../modlog.dart';
import 'Controller/controller.dart';
import 'Presentation/Pages/logging_launch_page.dart';

class LoggerScope extends StatefulWidget {
  const LoggerScope({
    super.key,
    this.customLoggers = const [],
    this.customActions = const [],
    required this.child,
  });

  final Widget child;
  final List<CustomLogger> customLoggers;
  final List<CustomAction> customActions;

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

  @override
  void didUpdateWidget(covariant LoggerScope oldWidget) {
    super.didUpdateWidget(oldWidget);
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
        initialData: loggerController.state.overlayState,
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
          return LoggerLaunchPage(
            minimized: minimized,
          );
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
    return CustomLoggerInheritedWidget(
      customLoggers: widget.customLoggers,
      customActions: widget.customActions,
      child: widget.child,
    );
  }
}

class CustomLoggerInheritedWidget extends InheritedWidget {
  final List<CustomLogger> customLoggers;
  final List<CustomAction> customActions;
  const CustomLoggerInheritedWidget({
    super.key,
    required super.child,
    required this.customLoggers,
    required this.customActions,
  });

  @override
  bool updateShouldNotify(CustomLoggerInheritedWidget oldWidget) =>
      customLoggers != oldWidget.customLoggers ||
      customActions != oldWidget.customActions;

  static CustomLoggerInheritedWidget? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CustomLoggerInheritedWidget>();
  }

  static CustomLoggerInheritedWidget of(BuildContext context) {
    final widget = maybeOf(context);
    assert(widget != null, 'No CustomLoggerInheritedWidget found in context');
    return widget!;
  }
}
