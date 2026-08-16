import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../models/app_install_result.dart';

@JS('muslingoIsInstalled')
external JSBoolean _isInstalled();

@JS('muslingoCanInstall')
external JSBoolean _canInstall();

@JS('muslingoNeedsIosInstallInstructions')
external JSBoolean _needsIosInstructions();

@JS('muslingoInstall')
external JSPromise<JSString> _install();

class AppInstallPlatform {
  static final _statusController = StreamController<void>.broadcast();
  static JSFunction? _statusListener;

  static bool get isWebInstallExperience => true;
  static bool get isInstalled => _isInstalled().toDart;
  static bool get canPrompt => _canInstall().toDart;
  static bool get needsIosInstructions => _needsIosInstructions().toDart;
  static Stream<void> get statusChanges {
    _ensureStatusListener();
    return _statusController.stream;
  }

  static void _ensureStatusListener() {
    if (_statusListener != null) return;
    _statusListener = ((web.Event _) {
      _statusController.add(null);
    }).toJS;
    web.window.addEventListener('muslingo-installed', _statusListener);
  }

  static Future<AppInstallResult> install() async {
    final result = (await _install().toDart).toDart;
    switch (result) {
      case 'accepted':
        return AppInstallResult.installed;
      case 'ios-instructions':
        return AppInstallResult.instructionsRequired;
      case 'dismissed':
        return AppInstallResult.dismissed;
      default:
        return AppInstallResult.unavailable;
    }
  }
}
