import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  testWidgets('renders without throwing', (tester) async {
    await tester.pumpWidget(
        wrap(const AppImage(url: 'https://example.com/img.png')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no borderRadius — no ClipRRect in tree', (tester) async {
    await tester.pumpWidget(
        wrap(const AppImage(url: 'https://example.com/img.png')));
    expect(find.byType(ClipRRect), findsNothing);
  });

  testWidgets('borderRadius — wraps in ClipRRect', (tester) async {
    await tester.pumpWidget(wrap(
      AppImage(
        url: 'https://example.com/img.png',
        borderRadius: AppRadius.borderCard,
      ),
    ));
    expect(find.byType(ClipRRect), findsOneWidget);
  });

  testWidgets('reflects width and height', (tester) async {
    await tester.pumpWidget(wrap(
      const AppImage(
        url: 'https://example.com/img.png',
        width: 120.0,
        height: 80.0,
      ),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 120.0);
    expect(image.height, 80.0);
  });

  testWidgets('reflects fit', (tester) async {
    await tester.pumpWidget(wrap(
      const AppImage(
        url: 'https://example.com/img.png',
        fit: BoxFit.contain,
      ),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.contain);
  });

  testWidgets('http(s) url renders via NetworkImage', (tester) async {
    await tester.pumpWidget(
        wrap(const AppImage(url: 'https://example.com/img.png')));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
  });

  testWidgets('non-url string renders via AssetImage', (tester) async {
    await tester.pumpWidget(
        wrap(const AppImage(url: 'lib/data/mocks/images/case-1.png')));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
  });
}
