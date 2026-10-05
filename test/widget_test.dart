import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:void_connect/app/void_connect_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const appLibraryChannel = MethodChannel('void_connect/app_library');
  var availableApps = <Map<String, String>>[];
  var savedAppIds = <String>[];
  var launchedAppIds = <String>[];
  var launchSucceeds = true;

  setUp(() {
    availableApps = [
      {'id': 'com.example.browser', 'name': 'Browser'},
      {'id': 'com.example.music', 'name': 'Music'},
    ];
    savedAppIds = [];
    launchedAppIds = [];
    launchSucceeds = true;
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
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLibraryChannel, null);
  });

  testWidgets('switches from Russian to English', (tester) async {
    await tester.pumpWidget(const VoidConnectApp());
    expect(find.text('Ранняя разработка'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Early development'), findsOneWidget);
    expect(find.text('Ранняя разработка'), findsNothing);
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

    await tester.tap(find.byTooltip('Добавить').last);
    await tester.pumpAndSettle();
    expect(savedAppIds, ['com.example.music']);
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    expect(find.text('Music'), findsOneWidget);
    await tester.tap(find.byTooltip('Запустить'));
    await tester.pumpAndSettle();
    expect(launchedAppIds, ['com.example.music']);

    await tester.tap(find.byTooltip('Убрать из библиотеки'));
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

    await tester.tap(find.byTooltip('Запустить'));
    await tester.pumpAndSettle();
    expect(find.text('Приложение недоступно или уже удалено.'), findsOneWidget);
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
