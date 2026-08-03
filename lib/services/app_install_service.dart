import '../models/app_install_result.dart';
export '../models/app_install_result.dart';
import 'app_install_service_stub.dart'
    if (dart.library.js_interop) 'app_install_service_web.dart' as platform;

class AppInstallService {
  static bool get isWebInstallExperience =>
      platform.AppInstallPlatform.isWebInstallExperience;

  static bool get isInstalled => platform.AppInstallPlatform.isInstalled;

  static bool get canPrompt => platform.AppInstallPlatform.canPrompt;

  static bool get needsIosInstructions =>
      platform.AppInstallPlatform.needsIosInstructions;

  static Future<AppInstallResult> install() =>
      platform.AppInstallPlatform.install();
}
