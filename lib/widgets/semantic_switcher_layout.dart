import 'package:flutter/material.dart';

Widget semanticSwitcherLayout(
  Widget? currentChild,
  List<Widget> previousChildren,
) {
  return Stack(
    alignment: Alignment.center,
    children: [
      for (final child in previousChildren)
        ExcludeSemantics(excluding: true, child: child),
      if (currentChild != null) currentChild,
    ],
  );
}
