import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/l10n/app_strings.dart';
import '../core/theme/void_theme.dart';
import '../features/launcher/presentation/launcher_page.dart';

class VoidConnectApp extends StatefulWidget {
  const VoidConnectApp({super.key});

  @override
  State<VoidConnectApp> createState() => _VoidConnectAppState();
}

class _VoidConnectAppState extends State<VoidConnectApp> {
  Locale _locale = const Locale('ru');

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Void Connect',
    debugShowCheckedModeBanner: false,
    theme: VoidTheme.dark,
    locale: _locale,
    supportedLocales: AppStrings.supportedLocales,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: LauncherPage(
      locale: _locale,
      onLocaleChanged: (locale) => setState(() => _locale = locale),
    ),
  );
}
