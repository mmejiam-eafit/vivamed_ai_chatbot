import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  testWidgets('renders an Icon widget', (tester) async {
    await tester.pumpWidget(wrap(const AppIcon(Icons.star)));
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('uses the provided IconData', (tester) async {
    await tester.pumpWidget(wrap(const AppIcon(Icons.star)));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.star);
  });

  testWidgets('defaults to AppColors.icon color', (tester) async {
    await tester.pumpWidget(wrap(const AppIcon(Icons.star)));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, AppColors.icon);
  });

  testWidgets('applies custom color', (tester) async {
    await tester.pumpWidget(
        wrap(const AppIcon(Icons.star, color: AppColors.iconAccent)));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, AppColors.iconAccent);
  });

  testWidgets('defaults to size 24.0', (tester) async {
    await tester.pumpWidget(wrap(const AppIcon(Icons.star)));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 24.0);
  });

  testWidgets('reflects custom size', (tester) async {
    await tester.pumpWidget(wrap(const AppIcon(Icons.star, size: 40.0)));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 40.0);
  });

  testWidgets('reflects semanticLabel', (tester) async {
    await tester.pumpWidget(
        wrap(const AppIcon(Icons.star, semanticLabel: 'star icon')));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.semanticLabel, 'star icon');
  });
}
