import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vec;

import '../../../../modlog.dart';
import '../../Controller/controller.dart';
import '../../logger.dart';

class FloatingLoggerButton extends StatefulWidget {
  const FloatingLoggerButton({
    super.key,
    required AnimationController animationController,
    required this.loggerController,
  }) : _animationController = animationController;

  final AnimationController _animationController;
  final LoggerController loggerController;

  @override
  State<FloatingLoggerButton> createState() => _FloatingLoggerButtonState();
}

class _FloatingLoggerButtonState extends State<FloatingLoggerButton> {
  List<CustomAction> get customActions =>
      CustomLoggerInheritedWidget.of(context).customActions;

  late final _animation = CurvedAnimation(
    parent: widget._animationController,
    curve: Curves.easeInOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Flow(
              clipBehavior: Clip.none,
              delegate: DebugFlowDelegate(_animation),
              children: [
                GestureDetector(
                  onLongPress: () {
                    widget._animationController.toggle();
                  },
                  child: IconButton(
                    onPressed: () {
                      widget.loggerController.openLogger(context);
                    },
                    icon: const Icon(Icons.bug_report),
                    style: ButtonStyle(
                      shadowColor: WidgetStatePropertyAll(
                        Colors.purple[900],
                      ),
                      side: WidgetStatePropertyAll(
                        BorderSide(
                          color: Colors.purple[200]!,
                          width: 2,
                        ),
                      ),
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.purple[100]),
                      elevation: const WidgetStatePropertyAll(5),
                    ),
                  ),
                ),
                ...customActions.map(
                  (e) => IconButton(
                    onPressed: () {
                      e.onTap();
                    },
                    icon: Icon(e.icon),
                    style: ButtonStyle(
                      shadowColor: WidgetStatePropertyAll(
                        Colors.purple[900],
                      ),
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.purple[100],
                      ),
                      elevation: const WidgetStatePropertyAll(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        builder: (context, child) {
          return SizedBox(
            height: (((_animation.value * customActions.length) + 1) * 48) + 10,
            width: 58,
            // MediaQuery.of(context).size.width,
            child: child!,
          );
        });
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
