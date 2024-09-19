import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../Controller/controller.dart';

class LoggerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LoggerAppBar({
    this.title,
    this.actions = const [],
    super.key,
  });
  final String? title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      actions: [
        ...actions,
        IconButton(
          onPressed: () {
            GetIt.I<LoggerController>().minimizeLogger(context);
          },
          icon: const Icon(Icons.minimize),
        ),
        IconButton(
          onPressed: () {
            GetIt.I<LoggerController>().closeLogger();
          },
          icon: const Icon(
            Icons.close,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
