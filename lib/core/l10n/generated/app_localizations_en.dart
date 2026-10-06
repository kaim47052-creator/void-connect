// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loading => 'Loading…';

  @override
  String get russianLanguage => 'Russian language';

  @override
  String get englishLanguage => 'English language';

  @override
  String launchNamed(String name) {
    return 'Launch $name';
  }

  @override
  String removeNamed(String name) {
    return 'Remove $name from library';
  }

  @override
  String addNamed(String name) {
    return 'Add $name';
  }

  @override
  String addedNamed(String name) {
    return '$name added';
  }

  @override
  String get tagline => 'One interface. Connected devices.';

  @override
  String get early => 'Early development';

  @override
  String get intro =>
      'An ecosystem and launcher for Windows and Android. Today: an interface foundation. Next: your devices, modules and extensions.';

  @override
  String get libraryTitle => 'App library';

  @override
  String get searchApps => 'Search apps';

  @override
  String get addApp => 'Add app';

  @override
  String get add => 'Add';

  @override
  String get added => 'Added';

  @override
  String get done => 'Done';

  @override
  String get launch => 'Launch';

  @override
  String get removeApp => 'Remove from library';

  @override
  String get libraryEmpty => 'Add apps from the list to see them here.';

  @override
  String get noAppsAvailable => 'No launchable apps were found.';

  @override
  String get noSearchResults => 'No apps match your search.';

  @override
  String get appUnavailable => 'The app is unavailable or has been removed.';

  @override
  String get appLaunchFailed => 'Could not launch the app.';

  @override
  String get libraryLoadFailed => 'Could not load the app library.';

  @override
  String get librarySaveFailed => 'Could not save changes to the library.';

  @override
  String get libraryUnavailable =>
      'The app library is unavailable on this platform.';

  @override
  String get retry => 'Retry';

  @override
  String get modules => 'Up next';

  @override
  String get planned => 'Planned';

  @override
  String get launcher => 'Launcher';

  @override
  String get launcherDetail => 'Application library and launching';

  @override
  String get sync => 'Devices';

  @override
  String get syncDetail => 'Secure synchronization across devices';

  @override
  String get plugins => 'Plugins';

  @override
  String get pluginsDetail => 'Extensions with permission controls';

  @override
  String get updates => 'Updates';

  @override
  String get updatesDetail => 'Package verification and recovery';

  @override
  String get footer =>
      'Interface prototype · Module functionality is not implemented yet';

  @override
  String get language => 'Interface language';

  @override
  String get languageSaveFailed =>
      'Could not save the language preference. It will reset when the app restarts.';
}
