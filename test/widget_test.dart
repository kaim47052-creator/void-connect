import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:void_connect/app/void_connect_app.dart';

void main() {
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
}
