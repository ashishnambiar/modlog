import 'package:flutter/material.dart';

class CustomAction {
  String label;
  VoidCallback onTap;
  IconData? icon;

  CustomAction({
    required this.label,
    required this.onTap,
    this.icon,
  });
}
