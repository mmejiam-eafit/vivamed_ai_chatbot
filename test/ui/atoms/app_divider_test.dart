import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_divider.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: SizedBox(width: 200, height: 200, child: child)),
      );

  // ── Axis ───────────────────────────────────────────────────────────────────

  testWidgets('horizontal axis renders Divider', (tester) async {
    await tester.pumpWidget(wrap(const AppDivider()));
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byType(VerticalDivider), findsNothing);
  });

  testWidgets('vertical axis renders VerticalDivider', (tester) async {
    await tester.pumpWidget(wrap(const AppDivider(axis: Axis.vertical)));
    expect(find.byType(VerticalDivider), findsOneWidget);
    expect(find.byType(Divider), findsNothing);
  });

  // ── Color ──────────────────────────────────────────────────────────────────

  testWidgets('defaults to borderSubdued color', (tester) async {
    await tester.pumpWidget(wrap(const AppDivider()));
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.color, AppColorsData.light.borderSubdued);
  });

  testWidgets('applies custom color', (tester) async {
    await tester.pumpWidget(
        wrap(const AppDivider(color: AppColors.border)));
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.color, AppColors.border);
  });

  testWidgets('vertical divider defaults to borderSubdued color', (tester) async {
    await tester.pumpWidget(wrap(const AppDivider(axis: Axis.vertical)));
    final divider =
        tester.widget<VerticalDivider>(find.byType(VerticalDivider));
    expect(divider.color, AppColorsData.light.borderSubdued);
  });

  testWidgets('defaults resolve against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(
        body: SizedBox(width: 200, height: 200, child: AppDivider()),
      ),
    ));
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.color, AppColorsData.dark.borderSubdued);
  });

  // ── thickness / indent ─────────────────────────────────────────────────────

  testWidgets('reflects thickness', (tester) async {
    await tester.pumpWidget(wrap(const AppDivider(thickness: 2.0)));
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.thickness, 2.0);
  });

  testWidgets('reflects indent', (tester) async {
    await tester.pumpWidget(wrap(const AppDivider(indent: 16.0)));
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.indent, 16.0);
  });

  testWidgets('reflects endIndent', (tester) async {
    await tester.pumpWidget(wrap(const AppDivider(endIndent: 8.0)));
    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.endIndent, 8.0);
  });
}
