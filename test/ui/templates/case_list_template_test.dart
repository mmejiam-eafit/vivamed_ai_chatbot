import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';

void main() {
  group('CaseListTemplate', () {
    testWidgets('renders appBar slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(title: const Text('Cases')),
            caseSlots: const [],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.text('Cases'), findsOneWidget);
    });

    testWidgets('renders all caseSlots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('case-1'), Text('case-2'), Text('case-3')],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.text('case-1'), findsOneWidget);
      expect(find.text('case-2'), findsOneWidget);
      expect(find.text('case-3'), findsOneWidget);
    });

    testWidgets('renders header slot when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            header: const Text('section header'),
          ),
        ),
      );
      expect(find.text('section header'), findsOneWidget);
    });

    testWidgets('header is absent when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.text('section header'), findsNothing);
    });

    testWidgets('renders statusBar slot when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            statusBar: const Text('status'),
          ),
        ),
      );
      expect(find.text('status'), findsOneWidget);
    });

    testWidgets('renders emptyState when caseSlots is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            emptyState: const Text('no cases'),
          ),
        ),
      );
      expect(find.text('no cases'), findsOneWidget);
    });

    testWidgets('emptyState keeps the screen margin when it wraps', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(),
        home: CaseListTemplate(
          appBar: AppBar(),
          caseSlots: const [],
          worklistTable: const SizedBox.shrink(),
          emptyState: Text('A message long enough to wrap ' * 4),
        ),
      ));
      final message = tester.getRect(find.textContaining('A message'));
      final body = tester.getRect(find.byType(Scaffold));
      expect(message.left, greaterThanOrEqualTo(body.left + AppSpacing.lg));
      expect(message.right, lessThanOrEqualTo(body.right - AppSpacing.lg));
    });

    testWidgets('emptyState is absent when caseSlots is non-empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a')],
            worklistTable: const Text('table'),
            emptyState: const Text('no cases'),
          ),
        ),
      );
      expect(find.text('no cases'), findsNothing);
    });

    // ── Compact: ListView (< mediumMinWidth) ──────────────────────────────

    testWidgets('uses ListView below mediumMinWidth', (tester) async {
      const width = AppLayout.mediumMinWidth - 1;
      tester.view.physicalSize = const Size(width * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.text('table'), findsNothing);
    });

    testWidgets('applies list padding on compact', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a')],
            worklistTable: const Text('table'),
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      final insets = listView.padding! as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);
    });

    // ── Medium: GridView (mediumMinWidth to expandedMinWidth) ─────────────

    testWidgets('uses a two-column Wrap at mediumMinWidth, not GridView', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(
        AppLayout.mediumMinWidth * 3,
        844 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.text('table'), findsNothing);
    });

    testWidgets('applies wrap spacing and padding contract at medium', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(
        AppLayout.mediumMinWidth * 3,
        800 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      final insets = scrollView.padding! as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, AppSpacing.lg);
      expect(wrap.runSpacing, AppSpacing.lg);

      // Both slots share the same, equal column width -- confirms a real
      // two-column split, not one slot claiming more than its share.
      final widthA = tester
          .getSize(
            find
                .ancestor(of: find.text('a'), matching: find.byType(SizedBox))
                .first,
          )
          .width;
      final widthB = tester
          .getSize(
            find
                .ancestor(of: find.text('b'), matching: find.byType(SizedBox))
                .first,
          )
          .width;
      expect(widthA, widthB);
    });

    // ── Gap 20: cells reflow instead of clipping ──────────────────────────

    testWidgets('a taller slot grows its row rather than being clipped', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(
        AppLayout.mediumMinWidth * 3,
        800 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Taller than the old fixed childAspectRatio: 1.4 cell would allow at
      // this width -- that delegate clipped or scrolled content like this
      // inside its own cell instead of letting the row grow.
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [
              SizedBox(height: 500, child: Text('tall card')),
              Text('short card'),
            ],
            worklistTable: const Text('table'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final tallSlotHeight = tester
          .getSize(
            find
                .ancestor(
                  of: find.text('tall card'),
                  matching: find.byType(SizedBox),
                )
                .first,
          )
          .height;
      expect(tallSlotHeight, greaterThanOrEqualTo(500));
    });

    testWidgets('survives 200% text scale without overflowing', (tester) async {
      tester.view.physicalSize = const Size(
        AppLayout.mediumMinWidth * 3,
        800 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            theme: buildAppTheme(),
            home: CaseListTemplate(
              appBar: AppBar(),
              caseSlots: const [
                Text('Chest X-Ray with a fairly long descriptive title'),
                Text('CT'),
              ],
              worklistTable: const Text('table'),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    // ── Expanded/ultrawide: worklistTable slot ────────────────────────────

    testWidgets('still uses the two-column Wrap at expandedMinWidth -- '
        'worklistTable needs threePaneMinWidth, same as Chat/Study Review', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(
        AppLayout.expandedMinWidth * 3,
        800 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.text('table'), findsNothing);
    });

    testWidgets('uses the worklistTable slot at threePaneMinWidth', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(
        AppLayout.threePaneMinWidth * 3,
        800 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.text('table'), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('caps the worklistTable at worklistMaxWidth at ultrawide', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(
        AppLayout.ultrawideMinWidth * 3,
        800 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );

      final box = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.text('table'),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(box.constraints.maxWidth, AppLayout.worklistMaxWidth);
    });

    // The cap is not ultrawide-only (DT §9.5, D-019): it applies at every wide
    // width and binds once the content area -- the window minus the 64px menu
    // rail -- exceeds worklistMaxWidth. A bare Text slot sizes itself and would
    // show none of this, so the slot here takes whatever width it is given.
    group('worklistTable width across the wide tiers', () {
      Future<double> tableWidthAt(WidgetTester tester, double width) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: CaseListTemplate(
              appBar: AppBar(),
              caseSlots: const [Text('a'), Text('b')],
              worklistTable: const SizedBox.expand(key: Key('table')),
              menuRail: const SizedBox(
                width: NavigationTokens.sideNavCollapsedWidth,
              ),
            ),
          ),
        );
        return tester.getSize(find.byKey(const Key('table'))).width;
      }

      testWidgets('below the cap it fills the content area, uncapped', (
        tester,
      ) async {
        // 1500 is already in the expanded tier, but 1500 - 64 = 1436 < 1440.
        expect(
          await tableWidthAt(tester, 1500),
          1500 - NavigationTokens.sideNavCollapsedWidth,
        );
      });

      testWidgets('is capped in the expanded tier, below ultrawide', (
        tester,
      ) async {
        expect(1560, lessThan(AppLayout.ultrawideMinWidth));
        expect(await tableWidthAt(tester, 1560), AppLayout.worklistMaxWidth);
      });

      testWidgets('stays at the cap at ultrawide, rather than shrinking', (
        tester,
      ) async {
        final atUltrawide = await tableWidthAt(
          tester,
          AppLayout.ultrawideMinWidth,
        );
        expect(atUltrawide, AppLayout.worklistMaxWidth);
        expect(await tableWidthAt(tester, 1920), AppLayout.worklistMaxWidth);
      });
    });

    testWidgets('emptyState still wins over worklistTable when empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(
        AppLayout.expandedMinWidth * 3,
        800 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            emptyState: const Text('no cases'),
          ),
        ),
      );
      expect(find.text('no cases'), findsOneWidget);
      expect(find.text('table'), findsNothing);
    });

    // ── Other ──────────────────────────────────────────────────────────────

    testWidgets('applies header padding contract', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            header: const Text('header'),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(of: find.text('header'), matching: find.byType(Padding)),
      );
      final insets = padding.padding as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);
      expect(insets.right, AppSpacing.lg);
      expect(insets.bottom, 0);
    });

    testWidgets('has Scaffold with surfacePage background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.light.surfacePage);
    });

    testWidgets('resolves against the dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.dark.surfacePage);
    });

    testWidgets('navBar is passed to Scaffold.bottomNavigationBar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            navBar: const Text('nav-bar-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNotNull);
      expect(find.text('nav-bar-slot'), findsOneWidget);
    });

    testWidgets('navBar is absent when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
    });

    // ── primaryNavDrawer: expanded/ultrawide only (desktop/web revisit) ────

    testWidgets('threePaneMinWidth: navBar is NOT shown even when provided -- '
        'primaryNavDrawer replaces it', (tester) async {
      tester.view.physicalSize = const Size(
        AppLayout.threePaneMinWidth * 3,
        800 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            navBar: const Text('nav-bar-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
      expect(find.text('nav-bar-slot'), findsNothing);
    });

    testWidgets('threePaneMinWidth: primaryNavDrawer is wired as '
        'Scaffold.drawer, no app bar', (tester) async {
      tester.view.physicalSize = const Size(
        AppLayout.threePaneMinWidth * 3,
        800 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(title: const Text('Cases')),
            caseSlots: const [],
            worklistTable: const Text('table'),
            primaryNavDrawer: const Text('primary-nav-drawer-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isNotNull);
      // No app bar at this tier to show a DrawerButton in anymore -- the
      // menu trigger lives at the bottom of menuRail instead.
      expect(scaffold.appBar, isNull);
      expect(find.text('Cases'), findsNothing);
    });

    testWidgets('threePaneMinWidth: menuRail renders, absent below it', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(
        AppLayout.threePaneMinWidth * 3,
        800 * 3,
      );
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            menuRail: const Text('menu-rail-slot'),
          ),
        ),
      );
      expect(find.text('menu-rail-slot'), findsOneWidget);
    });

    testWidgets(
      'expandedMinWidth (below threePaneMinWidth): still shows app bar '
      'and navBar, not primaryNavDrawer/menuRail -- the exact gap this '
      'boundary alignment closes',
      (tester) async {
        tester.view.physicalSize = const Size(
          AppLayout.expandedMinWidth * 3,
          800 * 3,
        );
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: CaseListTemplate(
              appBar: AppBar(title: const Text('Cases')),
              caseSlots: const [],
              worklistTable: const Text('table'),
              navBar: const Text('nav-bar-slot'),
              primaryNavDrawer: const Text('primary-nav-drawer-slot'),
              menuRail: const Text('menu-rail-slot'),
            ),
          ),
        );
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.appBar, isNotNull);
        expect(scaffold.bottomNavigationBar, isNotNull);
        expect(scaffold.drawer, isNull);
        expect(find.text('menu-rail-slot'), findsNothing);
      },
    );

    testWidgets('compact/medium: menuRail is ignored', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            menuRail: const Text('menu-rail-slot'),
          ),
        ),
      );
      expect(find.text('menu-rail-slot'), findsNothing);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.appBar, isNotNull);
    });

    testWidgets(
      'compact/medium: primaryNavDrawer is ignored, navBar still shows',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: CaseListTemplate(
              appBar: AppBar(),
              caseSlots: const [],
              worklistTable: const Text('table'),
              navBar: const Text('nav-bar-slot'),
              primaryNavDrawer: const Text('primary-nav-drawer-slot'),
            ),
          ),
        );
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.bottomNavigationBar, isNotNull);
        expect(scaffold.drawer, isNull);
        expect(find.text('primary-nav-drawer-slot'), findsNothing);
      },
    );

    // Where a slot ends up on the page, measured with slots that have no size
    // of their own beyond what the template gives them (DT §9.5): the results
    // start at the top, a header spans the content, and only a message
    // (empty state) is centered. Before this, a Center floated a short list at
    // the vertical middle and a Column centered the header at its own width.
    group('placement', () {
      Future<void> pumpAt(
        WidgetTester tester,
        Size size,
        CaseListTemplate template,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(theme: buildAppTheme(), home: template),
        );
      }

      testWidgets('wide: the table starts at the top, not the middle', (
        tester,
      ) async {
        await pumpAt(
          tester,
          const Size(1280, 800),
          CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const SizedBox(
              key: Key('table'),
              width: double.infinity,
              height: 120,
            ),
            menuRail: const SizedBox(
              width: NavigationTokens.sideNavCollapsedWidth,
            ),
          ),
        );
        // No app bar at this tier, so the content area starts at the top.
        expect(tester.getTopLeft(find.byKey(const Key('table'))).dy, 0.0);
      });

      testWidgets('medium: the cards start under the app bar, not the middle', (
        tester,
      ) async {
        await pumpAt(
          tester,
          const Size(800, 900),
          CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [SizedBox(key: Key('card'), height: 80)],
            worklistTable: const Text('table'),
          ),
        );
        expect(
          tester.getTopLeft(find.byKey(const Key('card'))).dy,
          kToolbarHeight + AppSpacing.lg,
        );
      });

      for (final (name, size, railWidth) in [
        ('compact', const Size(390, 800), 0.0),
        ('wide', const Size(1280, 800), NavigationTokens.sideNavCollapsedWidth),
      ]) {
        testWidgets('$name: a header with no width of its own spans the content',
            (tester) async {
          await pumpAt(
            tester,
            size,
            CaseListTemplate(
              appBar: AppBar(),
              caseSlots: const [],
              worklistTable: const SizedBox(),
              header: const SizedBox(key: Key('header'), height: 24),
              menuRail: railWidth == 0
                  ? null
                  : SizedBox(width: railWidth),
            ),
          );
          final header = find.byKey(const Key('header'));
          expect(
            tester.getSize(header).width,
            size.width - railWidth - 2 * AppSpacing.lg,
          );
          expect(
            tester.getTopLeft(header).dx,
            railWidth + AppSpacing.lg,
          );
        });
      }

      testWidgets('a header of text lines up with the list below, not centered',
          (tester) async {
        await pumpAt(
          tester,
          const Size(800, 900),
          CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [SizedBox(key: Key('card'), height: 80)],
            worklistTable: const Text('table'),
            header: const Text('3 similar cases found'),
          ),
        );
        expect(
          tester.getTopLeft(find.text('3 similar cases found')).dx,
          AppSpacing.lg,
        );
      });

      testWidgets('the empty state stays centered: it is a message, not a list',
          (tester) async {
        await pumpAt(
          tester,
          const Size(800, 900),
          CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            emptyState: const Text('none'),
          ),
        );
        final center = tester.getCenter(find.text('none'));
        expect(center.dx, closeTo(400, 0.5));
        // Between the app bar and the bottom of the window.
        expect(center.dy, closeTo((kToolbarHeight + 900) / 2, 0.5));
      });
    });
  });
}
