import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_avatar.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

// NetworkImage loading always fails in the test environment (HTTP 400).
// Suppress those errors so the tests can check widget properties without failing.
void _suppressNetworkImageErrors() {
  final orig = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception is NetworkImageLoadException) return;
    orig?.call(details);
  };
  addTearDown(() => FlutterError.onError = orig);
}

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── imageUrl variant ───────────────────────────────────────────────────────

  testWidgets('imageUrl: renders CircleAvatar with NetworkImage', (tester) async {
    _suppressNetworkImageErrors();
    await tester.pumpWidget(wrap(
      const AppAvatar(imageUrl: 'https://example.com/avatar.jpg'),
    ));
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isA<NetworkImage>());
  });

  testWidgets('imageUrl: uses surfaceBrandSecondary as fallback background',
      (tester) async {
    _suppressNetworkImageErrors();
    await tester.pumpWidget(wrap(
      const AppAvatar(imageUrl: 'https://example.com/avatar.jpg'),
    ));
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundColor, AppColors.surfaceBrandSecondary);
  });

  // ── initials variant ───────────────────────────────────────────────────────

  testWidgets('initials: renders the initials text', (tester) async {
    await tester.pumpWidget(wrap(const AppAvatar(initials: 'JD')));
    expect(find.text('JD'), findsOneWidget);
  });

  testWidgets('initials: text uses textOnBrand color', (tester) async {
    await tester.pumpWidget(wrap(const AppAvatar(initials: 'AB')));
    final text = tester.widget<Text>(find.text('AB'));
    expect(text.style?.color, AppColors.textOnBrand);
  });

  testWidgets('initials: background is surfaceBrandSecondary', (tester) async {
    await tester.pumpWidget(wrap(const AppAvatar(initials: 'AB')));
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundColor, AppColors.surfaceBrandSecondary);
  });

  // ── fallback variant (neither imageUrl nor initials) ───────────────────────

  testWidgets('fallback: renders person icon', (tester) async {
    await tester.pumpWidget(wrap(const AppAvatar()));
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('fallback: background is surfaceBrandSecondary', (tester) async {
    await tester.pumpWidget(wrap(const AppAvatar()));
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundColor, AppColors.surfaceBrandSecondary);
  });

  // ── radius ─────────────────────────────────────────────────────────────────

  testWidgets('defaults to radius 20.0', (tester) async {
    await tester.pumpWidget(wrap(const AppAvatar()));
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.radius, 20.0);
  });

  testWidgets('reflects custom radius', (tester) async {
    await tester.pumpWidget(wrap(const AppAvatar(radius: 32.0)));
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.radius, 32.0);
  });
}
