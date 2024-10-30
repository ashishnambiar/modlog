import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:vector_math/vector_math_64.dart' as vec;

import '../../../../modlog.dart';
import '../../Controller/controller.dart';
import '../Widgets/overlay_scaffold.dart';

class LoggerLaunchPage extends StatefulWidget {
  const LoggerLaunchPage({
    super.key,
    required this.minimized,
    required this.customActions,
  });
  final bool minimized;
  final List<DebugAction> customActions;

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
    late final anim = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: AnimatedCrossFade(
        crossFadeState: widget.minimized //
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
        secondChild: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Material(
                color: Colors.transparent,
                child: Flow(
                  delegate: DebugFlowDelegate(anim),
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        _animationController.toggle();
                      },
                      child: IconButton(
                        onPressed: () {
                          loggerController.openLogger(context);
                        },
                        icon: const Icon(Icons.bug_report),
                        style: ButtonStyle(
                          shadowColor: WidgetStatePropertyAll(
                            Colors.purple[900],
                          ),
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.purple[100]),
                          elevation: const WidgetStatePropertyAll(5),
                        ),
                      ),
                    ),
                    ...widget.customActions.map(
                      (e) => IconButton(
                        onPressed: () {
                          e.onTap();
                        },
                        icon: Icon(e.icon),
                        style: ButtonStyle(
                          shadowColor: WidgetStatePropertyAll(
                            Colors.purple[900],
                          ),
                          side: WidgetStatePropertyAll(
                            BorderSide(
                              color: Colors.purple[300]!,
                              width: 2,
                            ),
                          ),
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.purple[100]),
                          elevation: const WidgetStatePropertyAll(1),
                        ),
                      ),
                    ),
                  ],
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

class DebugFlowDelegate extends FlowDelegate {
  DebugFlowDelegate(this.animation) : super(repaint: animation);
  Animation<double> animation;

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(48 + 10, constraints.maxHeight);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    for (var i = context.childCount - 1; i >= 0; i--) {
      context.paintChild(
        i,
        transform: Matrix4.translation(
          vec.Vector3(
            0,
            context.size.height -
                context.getChildSize(i)!.height -
                10 -
                (animation.value * i * 50),
            0,
          ),
        )
          ..translate(i == 0 //
              ? vec.Vector3(0, 0, 0)
              : vec.Vector3(-(animation.value - 1) * 25, 0, 0))
          ..scale(
            i == 0 //
                ? vec.Vector3(1, 1, 1)
                : vec.Vector3(animation.value, 1, 1),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(DebugFlowDelegate oldDelegate) =>
      animation != oldDelegate.animation;
}
