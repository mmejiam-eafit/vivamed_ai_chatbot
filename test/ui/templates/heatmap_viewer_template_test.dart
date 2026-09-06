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

    testWidgets('has Scaffold with surfaceBrand background', (tester) async {
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
      expect(scaffold.backgroundColor, AppColors.surfaceBrand);
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
      expect(bottomBar.color, AppColors.surfaceBrand);
    });
  });
}
