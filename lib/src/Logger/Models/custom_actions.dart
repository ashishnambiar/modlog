import 'package:flutter/material.dart';

class DebugAction {
  String label;
  VoidCallback onTap;
  IconData? icon;

  DebugAction({
    required this.label,
    required this.onTap,
    this.icon,
  });
}
