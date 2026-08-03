import '../models/app_install_result.dart';

class AppInstallPlatform {
  static bool get isWebInstallExperience => false;
  static bool get isInstalled => true;
  static bool get canPrompt => false;
  static bool get needsIosInstructions => false;

  static Future<AppInstallResult> install() async =>
      AppInstallResult.unavailable;
}
