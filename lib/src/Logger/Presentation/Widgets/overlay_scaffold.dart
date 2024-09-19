import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../Controller/controller.dart';
import '../../Utils/logger_appbar.dart';
import '../Pages/logging.dart';
import '../Pages/network_interceptor_page.dart';

class OverlayScaffold extends StatefulWidget {
  const OverlayScaffold({super.key});

  @override
  State<OverlayScaffold> createState() => _OverlayScaffoldState();
}

class _OverlayScaffoldState extends State<OverlayScaffold> {
  var canPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        GetIt.I<LoggerController>().minimizeLogger(context);
      },
      child: Scaffold(
        appBar: const LoggerAppBar(title: 'Select'),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NetworkInterceptorPage(),
                    ),
                  );
                },
                child: const Text('Network'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoggingPage(),
                    ),
                  );
                },
                child: const Text('Logging'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant OverlayScaffold oldWidget) {
    setState(() {
      switch (GetIt.I<LoggerController>().state.overlayState) {
        case LoggerOverlayOpened():
          canPop = false;
        case LoggerOverlayClosed():
        case LoggerOverlayMinimized():
          canPop = true;
      }
    });
    super.didUpdateWidget(oldWidget);
  }
}
