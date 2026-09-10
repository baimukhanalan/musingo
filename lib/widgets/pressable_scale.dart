import 'package:flutter/material.dart';

/// Subtle press feedback shared by primary controls. Semantics and hit testing
/// remain owned by the child, and Reduce Motion disables the scale change.
class PressableScale extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double pressedScale;

  const PressableScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.975,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: reduceMotion || !_pressed ? 1 : widget.pressedScale,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
