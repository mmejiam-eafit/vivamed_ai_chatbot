import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/hub_action_card.dart';
import 'package:radiologist_helper/ui/templates/home_hub_template.dart';

void main() {
  group('HomeHubTemplate', () {
    HomeHubTemplate buildTemplate({
      Widget? primaryNavDrawer,
      Widget? menuRail,
    }) =>
        HomeHubTemplate(
          appBar: AppBar(title: const Text('Home')),
          uploadCard: HubActionCard(
            icon: Icons.upload_file,
            title: 'Upload a study',
            description: 'Analyze a new DICOM study',
            onTap: () {},
          ),
          viewStudiesCard: HubActionCard(
            icon: Icons.folder_outlined,
            title: 'View studies',
            description: 'Browse existing studies',
            onTap: () {},
          ),
          chatCard: HubActionCard(
            icon: Icons.chat_bubble_outline,
            title: 'Chat',
            description: 'Ask about any case',
            onTap: () {},
          ),
          primaryNavDrawer: primaryNavDrawer,
          menuRail: menuRail,
        );

    testWidgets('renders appBar slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('renders all three cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );
      expect(find.text('Upload a study'), findsOneWidget);
      expect(find.text('View studies'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
    });

    // ── Compact: stacked column (< mediumMinWidth) ────────────────────────

    testWidgets('stacks cards below mediumMinWidth', (tester) async {
      const width = AppLayout.mediumMinWidth - 1;
      tester.view.physicalSize = const Size(width * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );

      // The row branch wraps each card in Expanded; the column branch
      // doesn't use Expanded at all -- an unambiguous signal either way.
      expect(find.byType(Expanded), findsNothing);
    });

    // ── Medium and up: a single row ────────────────────────────────────────

    testWidgets('lays cards out in a row at mediumMinWidth and up',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );

      expect(find.byType(Expanded), findsNWidgets(3));
    });

    // The three cards are one row, so they share one height. With the Row
    // centered, each sat at its own height instead, vertically centered -- seen
    // at 200% text (DT §3.7), where "Chat"'s description wraps less than the
    // other two. A longer description on one card stands in for that here.
    for (final (name, width) in [
      ('medium', AppLayout.mediumMinWidth),
      ('wide', 1280.0),
    ]) {
      testWidgets('$name: cards share the tallest card\'s height, top-aligned',
          (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: HomeHubTemplate(
              appBar: AppBar(title: const Text('Home')),
              uploadCard: HubActionCard(
                icon: Icons.upload_file,
                title: 'Upload a study',
                description: 'Analyze a new DICOM study and send it to the '
                    'model for a first read of every series it contains',
                onTap: () {},
              ),
              viewStudiesCard: HubActionCard(
                icon: Icons.folder_outlined,
                title: 'View studies',
                description: 'Browse',
                onTap: () {},
              ),
              chatCard: HubActionCard(
                icon: Icons.chat_bubble_outline,
                title: 'Chat',
                description: 'Ask',
                onTap: () {},
              ),
            ),
          ),
        );

        final cards = find.byType(HubActionCard);
        final heights = [
          for (var i = 0; i < 3; i++) tester.getSize(cards.at(i)).height,
        ];
        final tops = [
          for (var i = 0; i < 3; i++) tester.getTopLeft(cards.at(i)).dy,
        ];
        // The long description makes the first card taller than the others
        // would be on their own, so equal heights means they were stretched.
        expect(heights[0], greaterThan(0));
        expect(heights[1], heights[0]);
        expect(heights[2], heights[0]);
        expect(tops[1], tops[0]);
        expect(tops[2], tops[0]);
      });
    }

    // ── primaryNavDrawer/menuRail: expanded/ultrawide only (DT §9.5) ───────

    testWidgets(
        'threePaneMinWidth: primaryNavDrawer is wired as Scaffold.drawer, '
        'no app bar', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: buildTemplate(
            primaryNavDrawer: const Text('primary-nav-drawer-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isNotNull);
      expect(scaffold.appBar, isNull);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('threePaneMinWidth: menuRail renders, absent below it',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: buildTemplate(menuRail: const Text('menu-rail-slot')),
        ),
      );
      expect(find.text('menu-rail-slot'), findsOneWidget);
    });

    testWidgets(
        'expandedMinWidth (below threePaneMinWidth): still shows the app '
        'bar, not primaryNavDrawer -- the exact gap this boundary alignment '
        'closes', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.expandedMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: buildTemplate(
            primaryNavDrawer: const Text('primary-nav-drawer-slot'),
            menuRail: const Text('menu-rail-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.appBar, isNotNull);
      expect(scaffold.drawer, isNull);
      expect(find.text('menu-rail-slot'), findsNothing);
    });

    // ── Dark theme ─────────────────────────────────────────────────────────

    testWidgets('resolves against the dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          home: buildTemplate(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.dark.surfacePage);
    });
  });
}
