import 'package:flutter/services.dart';

class HapticsService {
  const HapticsService._();

  static void tap() => HapticFeedback.selectionClick();

  static void correct() => HapticFeedback.lightImpact();

  static void wrong() => HapticFeedback.heavyImpact();

  static void reward() => HapticFeedback.mediumImpact();

  static void chest() => HapticFeedback.mediumImpact();

  static void streak() => HapticFeedback.heavyImpact();

  static void speechPassed() => HapticFeedback.mediumImpact();

  static void speechFailed() => HapticFeedback.heavyImpact();
}
