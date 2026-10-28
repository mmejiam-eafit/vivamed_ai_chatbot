import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_badge.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders Home, Chat, Studies, Review, and Settings labels',
      (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      pendingReviewCount: 0,
    )));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Studies'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  // ── Selected destination ───────────────────────────────────────────────────

  testWidgets('selectedIndex 0 shows the filled home icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      pendingReviewCount: 0,
    )));
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsNothing);
  });

  testWidgets('selectedIndex 1 shows the filled chat icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 1,
      onDestinationSelected: (_) {},
      pendingReviewCount: 0,
    )));
    expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
  });

  testWidgets('selectedIndex 2 shows the filled folder icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 2,
      onDestinationSelected: (_) {},
      pendingReviewCount: 0,
    )));
    expect(find.byIcon(Icons.folder), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsNothing);
  });

  testWidgets('selectedIndex 3 shows the filled flag icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 3,
      onDestinationSelected: (_) {},
      pendingReviewCount: 0,
    )));
    expect(find.byIcon(Icons.flag), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsNothing);
  });

  testWidgets('selectedIndex 4 shows the filled settings icon', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 4,
      onDestinationSelected: (_) {},
      pendingReviewCount: 0,
    )));
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsNothing);
  });

  // ── onDestinationSelected ──────────────────────────────────────────────────

  testWidgets('tapping Home calls onDestinationSelected with 0',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 1,
      onDestinationSelected: (i) => tapped = i,
      pendingReviewCount: 0,
    )));
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(tapped, 0);
  });

  testWidgets('tapping Studies calls onDestinationSelected with 2',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (i) => tapped = i,
      pendingReviewCount: 0,
    )));
    await tester.tap(find.text('Studies'));
    await tester.pump();
    expect(tapped, 2);
  });

  testWidgets('tapping Review calls onDestinationSelected with 3',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (i) => tapped = i,
      pendingReviewCount: 0,
    )));
    await tester.tap(find.text('Review'));
    await tester.pump();
    expect(tapped, 3);
  });

  testWidgets('tapping Settings calls onDestinationSelected with 4',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (i) => tapped = i,
      pendingReviewCount: 0,
    )));
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(tapped, 4);
  });

  // ── Review count (DL D-021) ────────────────────────────────────────────────

  testWidgets('no badge when nothing needs review', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      pendingReviewCount: 0,
    )));
    expect(find.byType(AppBadge), findsNothing);
  });

  testWidgets('Review carries the count of images needing review',
      (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      pendingReviewCount: 2,
    )));
    expect(find.byType(AppBadge), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    // Over the Review icon, not another destination's.
    expect(
      find.ancestor(of: find.text('2'), matching: find.byType(Stack)),
      findsWidgets,
    );
    final flag = tester.getRect(find.byIcon(Icons.flag_outlined));
    final badge = tester.getRect(find.byType(AppBadge));
    expect(badge.overlaps(flag), isTrue);
  });

  testWidgets('the count stays on Review when it is selected', (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 3,
      onDestinationSelected: (_) {},
      pendingReviewCount: 5,
    )));
    expect(find.text('5'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('the count is on the warning pair ($brightness)',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(
          body: AppNavBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            pendingReviewCount: 2,
          ),
        ),
      ));
      final colors = brightness == Brightness.light
          ? AppColorsData.light
          : AppColorsData.dark;
      final badge = tester.widget<AppBadge>(find.byType(AppBadge));
      expect(badge.backgroundColor, colors.statusWarningSubdued);
      expect(badge.textColor, colors.statusWarning);
    });
  }

  testWidgets('five destinations with a count fit 320px at 200% text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: Scaffold(
          bottomNavigationBar: AppNavBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            pendingReviewCount: 12,
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('12'), findsOneWidget);
  });

  // ── Background color ───────────────────────────────────────────────────────

  testWidgets('background uses NavigationTokens.bottomNavBackground',
      (tester) async {
    await tester.pumpWidget(wrap(AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      pendingReviewCount: 0,
    )));
    final container = tester.widget<Container>(find.byType(Container).first);
    final dec = container.decoration! as BoxDecoration;
    expect(dec.color, AppColorsData.light.surface);
    expect(dec.border!.top.color, AppColorsData.light.borderSubdued);
  });

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: Scaffold(
        body: AppNavBar(
          selectedIndex: 4,
          onDestinationSelected: (_) {},
          pendingReviewCount: 0,
        ),
      ),
    ));
    final container = tester.widget<Container>(find.byType(Container).first);
    final dec = container.decoration! as BoxDecoration;
    expect(dec.color, AppColorsData.dark.surface);
    expect(dec.border!.top.color, AppColorsData.dark.borderSubdued);

    final icon = tester.widget<Icon>(find.byIcon(Icons.settings));
    expect(icon.color, AppColorsData.dark.iconAccent);
  });
}
