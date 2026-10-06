import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:void_connect/app/void_connect_app.dart';
import 'package:void_connect/core/motion/void_motion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const appLibraryChannel = MethodChannel('void_connect/app_library');
  const settingsChannel = MethodChannel('void_connect/settings');
  const motionChannel = MethodChannel('void_connect/motion');
  var reduceMotion = false;
  var availableApps = <Map<String, String>>[];
  var savedAppIds = <String>[];
  var launchedAppIds = <String>[];
  var launchSucceeds = true;
  String? savedLanguage;

  setUp(() {
    availableApps = [
      {'id': 'com.example.browser', 'name': 'Browser'},
      {'id': 'com.example.music', 'name': 'Music'},
    ];
    savedAppIds = [];
    launchedAppIds = [];
    launchSucceeds = true;
    savedLanguage = null;
    reduceMotion = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(motionChannel, (call) async => reduceMotion);
    TestWidgetsFlutterBinding.instance.platformDispatcher.localeTestValue =
        const Locale('ru');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLibraryChannel, (call) async {
          switch (call.method) {
            case 'listApps':
              return availableApps;
            case 'getSavedApps':
              return savedAppIds;
            case 'addApp':
              final id = (call.arguments as Map)['id'] as String;
              if (!savedAppIds.contains(id)) savedAppIds.add(id);
              return null;
            case 'removeApp':
              final id = (call.arguments as Map)['id'] as String;
              savedAppIds.remove(id);
              return null;
            case 'launchApp':
              final id = (call.arguments as Map)['id'] as String;
              launchedAppIds.add(id);
              return launchSucceeds;
            default:
              throw MissingPluginException();
          }
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, (call) async {
          switch (call.method) {
            case 'getLanguage':
              return savedLanguage;
            case 'setLanguage':
              savedLanguage = (call.arguments as Map)['languageCode'] as String;
              return null;
            default:
              throw MissingPluginException();
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLibraryChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(motionChannel, null);
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearLocaleTestValue();
  });

  testWidgets('switches from Russian to English', (tester) async {
    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();
    expect(find.text('Ранняя разработка'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(savedLanguage, 'en');
    expect(find.text('Early development'), findsOneWidget);
    expect(find.text('Ранняя разработка'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();
    expect(find.text('Early development'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses Russian when the device language is unsupported', (
    tester,
  ) async {
    TestWidgetsFlutterBinding.instance.platformDispatcher.localeTestValue =
        const Locale('fr');
    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();
    expect(find.text('Ранняя разработка'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 1280.0]) {
    testWidgets('lays out without overflow at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const VoidConnectApp());
      await tester.pumpAndSettle();
      expect(find.text('Void Connect'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Обновления'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Обновления'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('adds, searches, launches, and removes an app', (tester) async {
    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Добавить приложение').first);
    await tester.pumpAndSettle();
    expect(find.text('Browser'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'music');
    await tester.pumpAndSettle();
    expect(find.text('Browser'), findsNothing);
    expect(find.text('Music'), findsOneWidget);

    await tester.tap(find.byTooltip('Добавить Music'));
    await tester.pumpAndSettle();
    expect(savedAppIds, ['com.example.music']);
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    expect(find.text('Music'), findsOneWidget);
    await tester.tap(find.byTooltip('Запустить Music'));
    await tester.pumpAndSettle();
    expect(launchedAppIds, ['com.example.music']);

    await tester.tap(find.byTooltip('Убрать Music из библиотеки'));
    await tester.pumpAndSettle();
    expect(savedAppIds, isEmpty);
    expect(
      find.text('Добавьте приложения из списка, чтобы они появились здесь.'),
      findsOneWidget,
    );
  });

  testWidgets('reports an app that is no longer launchable', (tester) async {
    launchSucceeds = false;
    savedAppIds = ['com.example.music'];
    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Запустить Music'));
    await tester.pumpAndSettle();
    expect(find.text('Приложение недоступно или уже удалено.'), findsOneWidget);
  });

  testWidgets('keyboard search, clearing and dialog focus return', (
    tester,
  ) async {
    savedAppIds = ['com.example.music'];
    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    // A different logical key models a keyboard layout with the physical F key.
    await tester.sendKeyEvent(
      LogicalKeyboardKey.keyA,
      physicalKey: PhysicalKeyboardKey.keyF,
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('Music'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Music'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.focusNode!.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(button.focusNode!.hasFocus, isTrue);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
  });

  testWidgets('reduced motion skips state and picker transitions', (
    tester,
  ) async {
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    savedAppIds = ['com.example.music'];
    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(MotionSwitcher),
        matching: find.byType(AnimatedSwitcher),
      ),
      findsNothing,
    );
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pump();
    expect(find.text('Music'), findsNothing);
    await tester.tap(find.text('Добавить приложение').first);
    await tester.pump();
    final route = ModalRoute.of(tester.element(find.byType(AlertDialog)))!;
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Windows OS motion preference applies and updates live', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    reduceMotion = true;
    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();
    final navigator = tester.element(find.byType(Navigator));
    expect(MediaQuery.disableAnimationsOf(navigator), isTrue);
    expect(
      find.descendant(
        of: find.byType(MotionSwitcher),
        matching: find.byType(AnimatedSwitcher),
      ),
      findsNothing,
    );
    tester.binding.channelBuffers.push(
      'void_connect/motion',
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('motionChanged', false),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    expect(MediaQuery.disableAnimationsOf(navigator), isFalse);
    expect(
      find.descendant(
        of: find.byType(MotionSwitcher),
        matching: find.byType(AnimatedSwitcher),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });

  for (final locale in ['ru', 'en']) {
    for (final width in [320.0, 1280.0]) {
      testWidgets('large text fits library and picker: $locale $width', (
        tester,
      ) async {
        savedLanguage = locale;
        availableApps = [
          {
            'id': 'long.app',
            'name': 'Очень длинное название приложения / A very long application name',
          },
        ];
        savedAppIds = ['long.app'];
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(
          tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
        );
        await tester.pumpWidget(const VoidConnectApp());
        await tester.pumpAndSettle();
        final addLabel = locale == 'ru' ? 'Добавить приложение' : 'Add app';
        await tester.scrollUntilVisible(
          find.text(addLabel).first,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(addLabel).first);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('controls have labels, sufficient targets and text contrast', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    savedAppIds = ['com.example.music'];
    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();
    expect(find.byTooltip('Запустить Music'), findsOneWidget);
    expect(find.byTooltip('Убрать Music из библиотеки'), findsOneWidget);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await tester.tap(find.text('Добавить приложение').first);
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('the app picker fits a narrow phone display', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VoidConnectApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Добавить приложение').first,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Добавить приложение').first);
    await tester.pumpAndSettle();

    expect(find.text('Browser'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
