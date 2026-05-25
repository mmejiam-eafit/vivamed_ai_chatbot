import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Variant: primary ───────────────────────────────────────────────────────

  testWidgets('primary variant renders ElevatedButton', (tester) async {
    await tester.pumpWidget(wrap(
      const AppButton(label: 'OK', onPressed: null),
    ));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('primary variant uses interactivePrimary background', (tester) async {
    await tester.pumpWidget(wrap(
      const AppButton(label: 'OK', onPressed: null),
    ));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final bg = button.style?.backgroundColor?.resolve({});
    expect(bg, AppColors.interactivePrimary);
  });

  // ── Variant: secondary ─────────────────────────────────────────────────────

  testWidgets('secondary variant renders OutlinedButton', (tester) async {
    await tester.pumpWidget(wrap(
      const AppButton(
          label: 'OK',
          onPressed: null,
          variant: AppButtonVariant.secondary),
    ));
    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  // ── Variant: ghost ─────────────────────────────────────────────────────────

  testWidgets('ghost variant renders TextButton', (tester) async {
    await tester.pumpWidget(wrap(
      const AppButton(
          label: 'OK', onPressed: null, variant: AppButtonVariant.ghost),
    ));
    expect(find.byType(TextButton), findsOneWidget);
  });

  // ── Variant: iconOnly ──────────────────────────────────────────────────────

  testWidgets('iconOnly variant renders IconButton', (tester) async {
    await tester.pumpWidget(wrap(
      const AppButton(
        icon: Icons.add,
        onPressed: null,
        variant: AppButtonVariant.iconOnly,
      ),
    ));
    expect(find.byType(IconButton), findsOneWidget);
  });

  // ── Content rendering ──────────────────────────────────────────────────────

  testWidgets('label text is shown', (tester) async {
    await tester.pumpWidget(wrap(
      const AppButton(label: 'Submit', onPressed: null),
    ));
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('icon is shown when provided with primary variant', (tester) async {
    await tester.pumpWidget(wrap(
      const AppButton(icon: Icons.send, label: 'Send', onPressed: null),
    ));
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  // ── Callbacks ──────────────────────────────────────────────────────────────

  testWidgets('onPressed fires on tap', (tester) async {
    var fired = false;
    await tester.pumpWidget(wrap(
      AppButton(label: 'Click', onPressed: () => fired = true),
    ));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(fired, isTrue);
  });

  testWidgets('onPressed null disables the button', (tester) async {
    await tester.pumpWidget(wrap(
      const AppButton(label: 'Click', onPressed: null),
    ));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  // ── isLoading ──────────────────────────────────────────────────────────────

  testWidgets('isLoading shows CircularProgressIndicator', (tester) async {
    await tester.pumpWidget(wrap(
      AppButton(label: 'Wait', onPressed: () {}, isLoading: true),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('isLoading disables tap', (tester) async {
    await tester.pumpWidget(wrap(
      AppButton(label: 'Wait', onPressed: () {}, isLoading: true),
    ));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('isLoading false shows label text', (tester) async {
    await tester.pumpWidget(wrap(
      AppButton(label: 'Ready', onPressed: () {}, isLoading: false),
    ));
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  // ── iconOnly isLoading ─────────────────────────────────────────────────────

  testWidgets('iconOnly isLoading shows CircularProgressIndicator', (tester) async {
    await tester.pumpWidget(wrap(
      AppButton(
        icon: Icons.add,
        onPressed: () {},
        variant: AppButtonVariant.iconOnly,
        isLoading: true,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
