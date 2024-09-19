import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../Controller/controller.dart';
import '../Widgets/overlay_scaffold.dart';

class LoggerLaunchPage extends StatefulWidget {
  const LoggerLaunchPage({
    super.key,
    required this.minimized,
  });
  final bool minimized;

  @override
  State<LoggerLaunchPage> createState() => _LoggerLaunchPageState();
}

class _LoggerLaunchPageState extends State<LoggerLaunchPage> {
  final loggerController = GetIt.I<LoggerController>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: AnimatedCrossFade(
        crossFadeState: widget.minimized //
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
        secondChild: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () {
                  loggerController.openLogger(context);
                },
                icon: const Icon(Icons.bug_report),
                style: ButtonStyle(
                  shadowColor: WidgetStatePropertyAll(
                    Colors.purple[900],
                  ),
                  backgroundColor: WidgetStatePropertyAll(Colors.purple[100]),
                  elevation: const WidgetStatePropertyAll(5),
                ),
              ),
            ),
          ),
        ),
        firstChild: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.black26,
          child: SafeArea(
            child: Container(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: OverlayScaffold(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
