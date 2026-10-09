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
      expect(scaffold.backgroundColor, diagnosticCanvasGround);
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
      // Sideways only: padding the control above and below as well shrank a
      // Slider's box (and so its touch area) to 24px inside the 56px bar.
      expect(insets.top, 0.0);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isA<ColoredBox>());
      final bottomBar = scaffold.bottomNavigationBar! as ColoredBox;
      expect(bottomBar.color, diagnosticCanvasGround);
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

    testWidgets('compact: control bar is pinned to 56px', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.compactMaxWidth * 3, 844 * 3);
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

    // A Slider takes all the height a bounded parent offers, and the
    // Text('control') stand-in above can't show that -- it has an intrinsic
    // height of its own. The real page passes a Slider, so the layout is
    // checked with one, at both tiers that use the bottom bar.
    for (final (name, width) in [
      ('compact', AppLayout.compactMaxWidth),
      ('medium', AppLayout.mediumMinWidth),
    ]) {
      testWidgets('$name: a Slider control stays bar-sized, canvas keeps the '
          'rest of the screen', (tester) async {
        tester.view.physicalSize = Size(width * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: HeatmapViewerTemplate(
              appBar: AppBar(),
              baseImage: const SizedBox(key: Key('base-image')),
              opacityControl: Slider(value: 0.5, onChanged: (_) {}),
            ),
          ),
        );

        // The Slider's box is the whole 56px bar (it pads sideways only), so
        // its touch area clears the 44px minimum.
        expect(tester.getSize(find.byType(Slider)).height, 56.0);
        expect(tester.getSize(find.byType(Slider)).height,
            greaterThanOrEqualTo(AppInteraction.minTouchTarget));
        // Below the app bar, so nothing in it is covered...
        expect(tester.getTopLeft(find.byType(Slider)).dy,
            greaterThanOrEqualTo(tester.getBottomLeft(find.byType(AppBar)).dy));
        // ...and the canvas gets everything between app bar and bar.
        expect(tester.getSize(find.byKey(const Key('base-image'))).height,
            844 - kToolbarHeight - 56.0);
      });
    }

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
      expect(rail.color, diagnosticCanvasGround);
    });

    // A tap in the bar but off the thin track still has to reach the Slider:
    // its box is what receives the touch. At 24px tall a tap 20px above the
    // track centre fell outside it and did nothing.
    for (final (name, width) in [
      ('compact', AppLayout.compactMaxWidth),
      ('medium', AppLayout.mediumMinWidth),
    ]) {
      testWidgets('$name: a tap 20px off the track still moves the Slider',
          (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        double? changedTo;
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: HeatmapViewerTemplate(
              appBar: AppBar(),
              baseImage: const SizedBox(),
              opacityControl: Slider(value: 0.5, onChanged: (v) => changedTo = v),
            ),
          ),
        );

        final box = tester.getRect(find.byType(Slider));
        await tester.tapAt(Offset(box.left + box.width * 0.9, box.center.dy - 20));
        expect(changedTo, isNotNull);
      });
    }

    // The whole study is shown (DL D-020): with a ratio, the image and the
    // overlay share one frame at exactly that ratio, centered on the canvas
    // ground, instead of each cropping to the canvas.
    group('imageAspectRatio', () {
      Future<void> pumpAt(
        WidgetTester tester,
        Size size, {
        double? ratio,
      }) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: HeatmapViewerTemplate(
              appBar: AppBar(),
              baseImage: const SizedBox(key: Key('base')),
              heatmapOverlay: const SizedBox(key: Key('overlay')),
              opacityControl: const Text('control'),
              imageAspectRatio: ratio,
            ),
          ),
        );
      }

      Rect rectOf(WidgetTester tester, String key) =>
          tester.getRect(find.byKey(Key(key)));

      // Canvas = window minus the app bar and the 56px bar (bottom controls) at
      // compact, or minus the app bar and the 280px rail at wide.
      for (final (name, size, canvas, ratio) in [
        ('compact, wide image', const Size(390, 844), const Size(390, 732), 2.0),
        ('compact, tall image', const Size(390, 844), const Size(390, 732), 0.5),
        ('wide, wide image', const Size(1280, 720), const Size(1000, 664), 2.0),
        ('wide, tall image', const Size(1280, 720), const Size(1000, 664), 0.5),
      ]) {
        testWidgets('$name: one frame at the ratio, centered, whole canvas '
            'otherwise', (tester) async {
          await pumpAt(tester, size, ratio: ratio);
          final base = rectOf(tester, 'base');
          final overlay = rectOf(tester, 'overlay');

          expect(base.width / base.height, closeTo(ratio, 0.001));
          // The overlay is laid out against the image, not the canvas.
          expect(overlay, base);
          // Largest frame of that ratio that fits, touching the canvas on one
          // axis and centered on the other.
          expect(base.width <= canvas.width + 0.01, isTrue);
          expect(base.height <= canvas.height + 0.01, isTrue);
          expect(
            (base.width - canvas.width).abs() < 0.01 ||
                (base.height - canvas.height).abs() < 0.01,
            isTrue,
          );
          const canvasTop = kToolbarHeight;
          expect(base.center.dy, closeTo(canvasTop + canvas.height / 2, 0.01));
        });
      }

      testWidgets('null ratio: both slots fill the canvas, as before', (
        tester,
      ) async {
        await pumpAt(tester, const Size(390, 844));
        expect(rectOf(tester, 'base').size, const Size(390, 732));
        expect(rectOf(tester, 'overlay'), rectOf(tester, 'base'));
      });
    });

    // The rail is a full-height column, and a Slider takes all the height it is
    // offered: unpinned, its box was ~800px tall around a 24px track, so a tap
    // anywhere in the rail moved the thumb. Pinned like the bottom bar, and
    // still centered where the track always rendered.
    for (final (name, width, height) in [
      ('expanded', AppLayout.expandedMinWidth, 844.0),
      ('ultrawide', AppLayout.ultrawideMinWidth, 900.0),
    ]) {
      testWidgets('$name: a Slider control is bar-sized in the rail, centered',
          (tester) async {
        tester.view.physicalSize = Size(width, height);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: HeatmapViewerTemplate(
              appBar: AppBar(),
              baseImage: const SizedBox(),
              opacityControl: Slider(value: 0.5, onChanged: (_) {}),
            ),
          ),
        );

        final slider = find.byType(Slider);
        expect(tester.getSize(slider).height, 56.0);
        final rail = find.ancestor(of: slider, matching: find.byType(Container));
        expect(tester.getSize(rail).width, 280.0);
        expect(tester.getCenter(slider).dy, tester.getCenter(rail).dy);
      });
    }

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
