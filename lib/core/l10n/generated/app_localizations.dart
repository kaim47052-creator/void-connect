import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @russianLanguage.
  ///
  /// In en, this message translates to:
  /// **'Russian language'**
  String get russianLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English language'**
  String get englishLanguage;

  /// No description provided for @launchNamed.
  ///
  /// In en, this message translates to:
  /// **'Launch {name}'**
  String launchNamed(String name);

  /// No description provided for @removeNamed.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from library'**
  String removeNamed(String name);

  /// No description provided for @addNamed.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String addNamed(String name);

  /// No description provided for @addedNamed.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String addedNamed(String name);

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'One interface. Connected devices.'**
  String get tagline;

  /// No description provided for @early.
  ///
  /// In en, this message translates to:
  /// **'Early development'**
  String get early;

  /// No description provided for @intro.
  ///
  /// In en, this message translates to:
  /// **'An ecosystem and launcher for Windows and Android. Today: an interface foundation. Next: your devices, modules and extensions.'**
  String get intro;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'App library'**
  String get libraryTitle;

  /// No description provided for @searchApps.
  ///
  /// In en, this message translates to:
  /// **'Search apps'**
  String get searchApps;

  /// No description provided for @addApp.
  ///
  /// In en, this message translates to:
  /// **'Add app'**
  String get addApp;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @launch.
  ///
  /// In en, this message translates to:
  /// **'Launch'**
  String get launch;

  /// No description provided for @removeApp.
  ///
  /// In en, this message translates to:
  /// **'Remove from library'**
  String get removeApp;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add apps from the list to see them here.'**
  String get libraryEmpty;

  /// No description provided for @noAppsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No launchable apps were found.'**
  String get noAppsAvailable;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No apps match your search.'**
  String get noSearchResults;

  /// No description provided for @appUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The app is unavailable or has been removed.'**
  String get appUnavailable;

  /// No description provided for @appLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not launch the app.'**
  String get appLaunchFailed;

  /// No description provided for @libraryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the app library.'**
  String get libraryLoadFailed;

  /// No description provided for @librarySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes to the library.'**
  String get librarySaveFailed;

  /// No description provided for @libraryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The app library is unavailable on this platform.'**
  String get libraryUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @modules.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get modules;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @launcher.
  ///
  /// In en, this message translates to:
  /// **'Launcher'**
  String get launcher;

  /// No description provided for @launcherDetail.
  ///
  /// In en, this message translates to:
  /// **'Application library and launching'**
  String get launcherDetail;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get sync;

  /// No description provided for @syncDetail.
  ///
  /// In en, this message translates to:
  /// **'Secure synchronization across devices'**
  String get syncDetail;

  /// No description provided for @plugins.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get plugins;

  /// No description provided for @pluginsDetail.
  ///
  /// In en, this message translates to:
  /// **'Extensions with permission controls'**
  String get pluginsDetail;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @updatesDetail.
  ///
  /// In en, this message translates to:
  /// **'Package verification and recovery'**
  String get updatesDetail;

  /// No description provided for @footer.
  ///
  /// In en, this message translates to:
  /// **'Interface prototype · Module functionality is not implemented yet'**
  String get footer;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get language;

  /// No description provided for @languageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the language preference. It will reset when the app restarts.'**
  String get languageSaveFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
