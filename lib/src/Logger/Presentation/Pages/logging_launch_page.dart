import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../Controller/controller.dart';
import '../Widgets/floating_logger_button.dart';
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

class _LoggerLaunchPageState extends State<LoggerLaunchPage>
    with SingleTickerProviderStateMixin {
  final loggerController = GetIt.I<LoggerController>();
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: AnimatedCrossFade(
            crossFadeState: widget.minimized //
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            secondChild: Align(
              alignment: Alignment.bottomRight,
              child: FloatingLoggerButton(
                animationController: _animationController,
                loggerController: loggerController,
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
        ),
      ],
    );
  }
}
