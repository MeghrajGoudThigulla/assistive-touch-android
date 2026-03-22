// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Assistive Touch';

  @override
  String get homeScreenStart => 'Start Assistive Touch';

  @override
  String get homeScreenStop => 'Stop Assistive Touch';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get permissionGuidanceMsg =>
      'Allow Display over other apps to show the floating button.';
}
