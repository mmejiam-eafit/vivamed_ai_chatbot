import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  testWidgets('renders CircularProgressIndicator', (tester) async {
    await tester.pumpWidget(wrap(const AppLoadingIndicator()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('defaults to interactivePrimary color', (tester) async {
    await tester.pumpWidget(wrap(const AppLoadingIndicator()));
    final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator));
    expect(indicator.color, AppColors.interactivePrimary);
  });

  testWidgets('applies custom color', (tester) async {
    await tester.pumpWidget(
        wrap(const AppLoadingIndicator(color: AppColors.statusError)));
    final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator));
    expect(indicator.color, AppColors.statusError);
  });

  testWidgets('defaults to size 24.0', (tester) async {
    await tester.pumpWidget(wrap(const AppLoadingIndicator()));
    expect(
      find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 24.0 && w.height == 24.0),
      findsOneWidget,
    );
  });

  testWidgets('reflects custom size', (tester) async {
    await tester.pumpWidget(wrap(const AppLoadingIndicator(size: 48.0)));
    expect(
      find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 48.0 && w.height == 48.0),
      findsOneWidget,
    );
  });

  testWidgets('reflects strokeWidth', (tester) async {
    await tester.pumpWidget(wrap(const AppLoadingIndicator(strokeWidth: 4.0)));
    final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator));
    expect(indicator.strokeWidth, 4.0);
  });

  testWidgets('defaults strokeWidth to 2.5', (tester) async {
    await tester.pumpWidget(wrap(const AppLoadingIndicator()));
    final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator));
    expect(indicator.strokeWidth, 2.5);
  });
}
