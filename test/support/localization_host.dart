import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Match production localization so Arabic UI tests exercise real RTL instead
/// of merely substituting Arabic labels inside the default English/LTR host.
const testSupportedLocales = [
  Locale('ru'),
  Locale('kk'),
  Locale('en'),
  Locale('ar'),
];

const testLocalizationDelegates = <LocalizationsDelegate<dynamic>>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
