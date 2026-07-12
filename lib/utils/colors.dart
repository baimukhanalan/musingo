import 'package:flutter/material.dart';

class AppColors {
  // Brand colors sampled from the Muslingo cat artwork.
  static const Color white = Color(0xFFFFFFFF);
  static const Color sky = Color(0xFF62C5EE);
  static const Color skyLight = Color(0xFFDDF4FF);
  static const Color navy = Color(0xFF155B88);
  static const Color navyDark = Color(0xFF123D5B);
  static const Color coral = Color(0xFFFF756D);
  static const Color ivory = Color(0xFFFFFBF4);

  // Compatibility aliases used throughout the existing UI.
  static const Color pistachioLight = skyLight;
  static const Color pistachio = sky;
  static const Color pistachioDark = navy;

  // Текст
  static const Color textDark = Color(0xFF18364D);
  static const Color textGrey = Color(0xFF62798B);
  static const Color textLight = Color(0xFFA9BAC6);

  // Статусы
  static const Color success = Color(0xFF35B77A);
  static const Color error = coral;
  static const Color errorLight = Color(0xFFFFDEDA);
  static const Color warning = Color(0xFFF3B948);

  // Золотой
  static const Color gold = Color(0xFFF3B948);
  static const Color goldLight = Color(0xFFFFF0C9);

  // Фон
  static const Color background = ivory;
  static const Color backgroundGrey = Color(0xFFF1F7FA);
  static const Color border = Color(0xFFD7E5ED);

  // Кнопки
  static const Color buttonPrimary = sky;
  static const Color buttonDisabled = Color(0xFFB9C8D1);

  // Кот
  static const Color catBody = sky;
  static const Color catDark = navy;
  static const Color catNose = coral;
}
