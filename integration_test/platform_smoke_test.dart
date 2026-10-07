import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:void_connect/app/void_connect_app.dart';
import 'package:void_connect/core/l10n/generated/app_localizations.dart';
import 'package:void_connect/core/settings/data/language_settings_platform.dart';
import 'package:void_connect/features/launcher/data/app_library_platform.dart';

// Run against the real runner, without mocking the application's channels.
// The only library entry created here is removed in a finally block.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const library = AppLibraryPlatform();
  const settings = LanguageSettingsPlatform();
  const motion = MethodChannel('void_connect/motion');

  Matcher platformError(String code) => throwsA(
    isA<PlatformException>().having((error) => error.code, 'code', code),
  );

  testWidgets('native app discovery returns unique usable identifiers', (
    tester,
  ) async {
    final apps = await library.listAvailableApps();
    expect(apps, isNotEmpty);
    expect(apps.map((app) => app.id).toSet().length, apps.length);
    expect(
      apps.every((app) => app.id.isNotEmpty && app.name.isNotEmpty),
      isTrue,
    );
    if (Platform.isWindows) {
      expect(
        apps.every((app) => app.id.toLowerCase().endsWith('.lnk')),
        isTrue,
      );
    } else {
      expect(
        apps.map((app) => app.id),
        isNot(contains('dev.voidconnect.void_connect')),
      );
    }
  });

  testWidgets('native library round trip is idempotent and preserves entries', (
    tester,
  ) async {
    final before = await library.getSavedAppIds();
    final id = 'void-connect-test-${DateTime.now().microsecondsSinceEpoch}-Ж';
    try {
      await library.addApp(id);
      await library.addApp(id);
      final saved = await library.getSavedAppIds();
      expect(saved.where((value) => value == id), hasLength(1));
      expect(saved, containsAll(before));
      await library.removeApp(id);
      await library.removeApp(id);
      expect(await library.getSavedAppIds(), unorderedEquals(before));
    } finally {
      await library.removeApp(id);
    }
  });

  testWidgets(
    'native library rejects empty identifiers without changing data',
    (tester) async {
      final before = await library.getSavedAppIds();
      await expectLater(library.addApp(''), platformError('invalid_argument'));
      await expectLater(
        library.removeApp(''),
        platformError('invalid_argument'),
      );
      await expectLater(
        library.launchApp(''),
        platformError('invalid_argument'),
      );
      expect(await library.getSavedAppIds(), unorderedEquals(before));
    },
  );

  testWidgets('native launch reports invalid or missing app safely', (
    tester,
  ) async {
    if (Platform.isWindows) {
      // An invalid extension is rejected before ShellExecute opens anything.
      await expectLater(
        library.launchApp('void-connect-test.txt'),
        platformError('invalid_argument'),
      );
    } else {
      await expectLater(
        library.launchApp('dev.voidconnect.nonexistent_test'),
        platformError('app_not_found'),
      );
    }
  });

  testWidgets('native language validation and saved preference round trip', (
    tester,
  ) async {
    final before = await settings.getLanguage();
    await expectLater(
      settings.setLanguage('invalid-test-language'),
      platformError('invalid_argument'),
    );
    expect(await settings.getLanguage(), before);
    // A missing preference cannot be reset through the public API. Preserve it.
    if (before != null) {
      try {
        await settings.setLanguage('ru');
        expect(await settings.getLanguage(), 'ru');
        await settings.setLanguage('en');
        expect(await settings.getLanguage(), 'en');
      } finally {
        await settings.setLanguage(before);
      }
    }
  });

  testWidgets('actual app starts and opens the picker with native channels', (
    tester,
  ) async {
    if (Platform.isWindows) {
      expect(await motion.invokeMethod<bool>('getReduceMotion'), isA<bool>());
    }
    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();
    // Native replies may arrive after the last scheduled frame, especially on
    // a cold CI runner. Wait for the loaded library rather than a fixed delay.
    final addButton = find.byType(FilledButton);
    for (var attempt = 0; attempt < 100; attempt++) {
      if (addButton.evaluate().isNotEmpty &&
          tester.widget<FilledButton>(addButton).onPressed != null) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(addButton, findsOneWidget);
    expect(tester.widget<FilledButton>(addButton).onPressed, isNotNull);
    expect(find.text('Void Connect'), findsWidgets);
    final strings = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    final add = find.text(strings.addApp);
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text(strings.done));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
