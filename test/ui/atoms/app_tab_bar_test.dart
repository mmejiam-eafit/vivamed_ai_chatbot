import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_tab_bar.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: child),
      );

  final tabBar = AppTabBar(
    tabs: const ['Findings', 'Chat'],
    tabViews: const [Text('findings-view'), Text('chat-view')],
  );

  testWidgets('renders every tab label', (tester) async {
    await tester.pumpWidget(wrap(tabBar));
    expect(find.text('Findings'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
  });

  testWidgets('shows the first tab view by default', (tester) async {
    await tester.pumpWidget(wrap(tabBar));
    expect(find.text('findings-view'), findsOneWidget);
  });

  testWidgets('tapping a tab switches to its view', (tester) async {
    await tester.pumpWidget(wrap(tabBar));
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('chat-view'), findsOneWidget);
  });

  testWidgets('requires one view per tab', (tester) async {
    expect(
      () => AppTabBar(tabs: const ['Findings', 'Chat'], tabViews: const [Text('only-one')]),
      throwsAssertionError,
    );
  });

  testWidgets('TabBar colors resolve from context.colors', (tester) async {
    await tester.pumpWidget(wrap(tabBar));
    final bar = tester.widget<TabBar>(find.byType(TabBar));
    expect(bar.indicatorColor, AppColorsData.light.interactivePrimary);
    expect(bar.labelColor, AppColorsData.light.interactivePrimary);
    expect(bar.unselectedLabelColor, AppColorsData.light.textSecondary);
  });

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(wrap(tabBar, brightness: Brightness.dark));
    final bar = tester.widget<TabBar>(find.byType(TabBar));
    expect(bar.indicatorColor, AppColorsData.dark.interactivePrimary);
    expect(bar.labelColor, AppColorsData.dark.interactivePrimary);
    expect(bar.unselectedLabelColor, AppColorsData.dark.textSecondary);
  });
}
