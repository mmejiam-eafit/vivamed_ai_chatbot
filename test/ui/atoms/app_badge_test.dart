import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_badge.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

BoxDecoration _badgeDecoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).borderRadius != null,
    ),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  testWidgets('renders label text', (tester) async {
    await tester.pumpWidget(wrap(const AppBadge(label: 'New')));
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('defaults to interactivePrimary background', (tester) async {
    await tester.pumpWidget(wrap(const AppBadge(label: 'X')));
    expect(_badgeDecoration(tester).color, AppColors.interactivePrimary);
  });

  testWidgets('defaults to interactivePrimaryForeground text color',
      (tester) async {
    await tester.pumpWidget(wrap(const AppBadge(label: 'X')));
    final text = tester.widget<Text>(find.text('X'));
    expect(text.style?.color, AppColors.interactivePrimaryForeground);
  });

  testWidgets('applies custom backgroundColor', (tester) async {
    await tester.pumpWidget(wrap(
      const AppBadge(label: 'Error', backgroundColor: AppColors.statusError),
    ));
    expect(_badgeDecoration(tester).color, AppColors.statusError);
  });

  testWidgets('applies custom textColor', (tester) async {
    await tester.pumpWidget(wrap(
      const AppBadge(label: 'X', textColor: AppColors.textOnBrand),
    ));
    final text = tester.widget<Text>(find.text('X'));
    expect(text.style?.color, AppColors.textOnBrand);
  });

  testWidgets('uses labelSm font size', (tester) async {
    await tester.pumpWidget(wrap(const AppBadge(label: 'X')));
    final text = tester.widget<Text>(find.text('X'));
    expect(text.style?.fontSize, AppTypography.labelSm.fontSize);
  });
}
