import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/motion/void_motion.dart';
import '../core/motion/system_motion_scope.dart';
import '../core/settings/data/language_settings_platform.dart';
import '../core/theme/void_theme.dart';
import '../features/launcher/data/app_library_platform.dart';
import '../features/launcher/presentation/launcher_page.dart';

class VoidConnectApp extends StatefulWidget {
  const VoidConnectApp({
    super.key,
    this.appLibraryPlatform = const AppLibraryPlatform(),
    this.languageSettingsPlatform = const LanguageSettingsPlatform(),
  });

  final AppLibraryPlatform appLibraryPlatform;
  final LanguageSettingsPlatform languageSettingsPlatform;

  @override
  State<VoidConnectApp> createState() => _VoidConnectAppState();
}

class _VoidConnectAppState extends State<VoidConnectApp> {
  Locale _locale = const Locale('ru');
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    String? savedLanguage;
    try {
      savedLanguage = await widget.languageSettingsPlatform.getLanguage();
    } on PlatformException {
      // Use the device locale when native settings are temporarily unavailable.
    } on MissingPluginException {
      // This also keeps the app usable in widget tests and unsupported hosts.
    }

    final language = switch (savedLanguage) {
      'ru' => 'ru',
      'en' => 'en',
      _ => _deviceLanguageCode(),
    };
    if (!mounted) return;
    setState(() {
      _locale = Locale(language);
      _ready = true;
    });
  }

  String _deviceLanguageCode() {
    final languageCode = WidgetsBinding
        .instance
        .platformDispatcher
        .locale
        .languageCode
        .toLowerCase();
    return AppLocalizations.supportedLocales.any(
          (locale) => locale.languageCode == languageCode,
        )
        ? languageCode
        : 'ru';
  }

  Future<bool> _changeLanguage(Locale locale) async {
    try {
      await widget.languageSettingsPlatform.setLanguage(locale.languageCode);
      if (mounted) setState(() => _locale = locale);
      return true;
    } on PlatformException {
      if (mounted) setState(() => _locale = locale);
      return false;
    } on MissingPluginException {
      if (mounted) setState(() => _locale = locale);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Void Connect',
    debugShowCheckedModeBanner: false,
    theme: VoidTheme.dark,
    locale: _locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => SystemMotionScope(child: child!),
    home: _ready
        ? LauncherPage(
            onLocaleChanged: _changeLanguage,
            appLibraryPlatform: widget.appLibraryPlatform,
          )
        : Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: LoadingIndicator(
                  label: AppLocalizations.of(context)!.loading,
                ),
              ),
            ),
          ),
  );
}
