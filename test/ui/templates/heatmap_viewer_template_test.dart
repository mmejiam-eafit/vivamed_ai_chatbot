import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/heatmap_viewer_template.dart';

void main() {
  group('HeatmapViewerTemplate', () {
    testWidgets('renders appBar slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(title: const Text('viewer')),
            baseImage: const SizedBox(),
            opacityControl: const SizedBox(),
          ),
        ),
      );
      expect(find.text('viewer'), findsOneWidget);
    });

    testWidgets('renders baseImage slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(),
            baseImage: const Text('base-image'),
            opacityControl: const SizedBox(),
          ),
        ),
      );
      expect(find.text('base-image'), findsOneWidget);
    });

    testWidgets('renders opacityControl slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(),
            baseImage: const SizedBox(),
            opacityControl: const Text('opacity-ctrl'),
          ),
        ),
      );
      expect(find.text('opacity-ctrl'), findsOneWidget);
    });

    testWidgets('renders heatmapOverlay when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(),
            baseImage: const SizedBox(),
            heatmapOverlay: const Text('heatmap'),
            opacityControl: const SizedBox(),
          ),
        ),
      );
      expect(find.text('heatmap'), findsOneWidget);
    });

    testWidgets('heatmapOverlay is absent when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(),
            baseImage: const SizedBox(),
            opacityControl: const SizedBox(),
          ),
        ),
      );
      expect(find.text('heatmap'), findsNothing);
    });

    testWidgets('canvas is grounded in the diagnostic canvas token',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(),
            baseImage: const SizedBox(),
            opacityControl: const SizedBox(),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, DiagnosticImageTokens.canvasGround);
      // Not a semantic surface — picking one for being "dark enough" is the
      // reasoning D-001 forbids, and surfaceBrand moves with theme mode.
      expect(scaffold.backgroundColor, isNot(AppColors.surfaceBrand));
    });

    // D-004: the canvas is outside the theme. This is the assertion that makes
    // that checkable — the ground must not move when the mode does.
    testWidgets('canvas ground is identical in light and dark', (tester) async {
      Future<Color?> groundFor(Brightness brightness) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness),
            home: HeatmapViewerTemplate(
              appBar: AppBar(),
              baseImage: const SizedBox(),
              opacityControl: const SizedBox(),
            ),
          ),
        );
        return tester
            .widget<Scaffold>(find.byType(Scaffold))
            .backgroundColor;
      }

      expect(await groundFor(Brightness.light),
          await groundFor(Brightness.dark));
    });

    testWidgets('body uses Stack to layer image and overlay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(),
            baseImage: const Text('base'),
            heatmapOverlay: const Text('overlay'),
            opacityControl: const SizedBox(),
          ),
        ),
      );
      // Both baseImage and heatmapOverlay are rendered — they share the Stack body.
      expect(find.text('base'), findsOneWidget);
      expect(find.text('overlay'), findsOneWidget);
      // At least one Stack exists in the body (the AppBar also uses Stack internally).
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('applies bottom control padding and stack fit contract',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(),
            baseImage: const SizedBox(),
            opacityControl: const Text('control'),
          ),
        ),
      );

      final stack = tester.widgetList<Stack>(find.byType(Stack)).first;
      expect(stack.fit, StackFit.expand);

      final padding = tester.widget<Padding>(
        find.ancestor(of: find.text('control'), matching: find.byType(Padding)),
      );
      final insets = padding.padding as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isA<ColoredBox>());
      final bottomBar = scaffold.bottomNavigationBar! as ColoredBox;
      expect(bottomBar.color, DiagnosticImageTokens.canvasGround);
    });

    // ── Responsive tiers (DT §9.5) ─────────────────────────────────────────

    testWidgets('medium: control bar is pinned to 56px', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(),
            baseImage: const SizedBox(),
            opacityControl: const Text('control'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final bottomBar = scaffold.bottomNavigationBar! as ColoredBox;
      expect((bottomBar.child! as SizedBox).height, 56.0);
    });

    testWidgets('expanded: controls move to a 280px right rail, no bottom bar',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.expandedMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(),
            baseImage: const SizedBox(),
            opacityControl: const Text('control'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);

      final railFinder = find.ancestor(
        of: find.text('control'),
        matching: find.byType(Container),
      );
      expect(tester.getSize(railFinder).width, 280.0);
      final rail = tester.widget<Container>(railFinder);
      expect(rail.color, DiagnosticImageTokens.canvasGround);
    });

    testWidgets('ultrawide: also uses the right rail, not the bottom bar',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.ultrawideMinWidth * 3, 900 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: HeatmapViewerTemplate(
            appBar: AppBar(),
            baseImage: const SizedBox(),
            opacityControl: const Text('control'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
      expect(find.text('control'), findsOneWidget);
    });
  });
}
