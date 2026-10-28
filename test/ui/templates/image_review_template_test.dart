import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/image_review_template.dart';

const _flagged = Key('flagged');
const _other1 = Key('other-1');
const _other2 = Key('other-2');
const _panel = Key('panel');
const _report1 = Key('report-1');
const _report2 = Key('report-2');

void main() {
  Widget wrap({
    List<Widget> otherImages = const [
      SizedBox.expand(key: _other1),
      SizedBox.expand(key: _other2),
    ],
    double textScale = 1.0,
    Brightness brightness = Brightness.light,
  }) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: ImageReviewTemplate(
            appBar: AppBar(title: const Text('Image review')),
            flaggedImage: const SizedBox.expand(key: _flagged),
            otherImages: otherImages,
            reviewPanel: const SizedBox(height: 300, key: _panel),
            reportSections: const [
              SizedBox(height: 100, key: _report1),
              SizedBox(height: 100, key: _report2),
            ],
          ),
        ),
      );

  void setSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  const narrow = Size(390, 844);
  const wide = Size(AppLayout.twoPaneMinWidth, 768);

  group('slots', () {
    testWidgets('renders every slot', (tester) async {
      setSize(tester, wide);
      await tester.pumpWidget(wrap());

      expect(find.text('Image review'), findsOneWidget);
      for (final key in [_flagged, _other1, _other2, _panel, _report1]) {
        expect(find.byKey(key), findsOneWidget, reason: '$key');
      }
    });

    testWidgets('report sections follow the panel, in order', (tester) async {
      setSize(tester, wide);
      await tester.pumpWidget(wrap());

      final panel = tester.getTopLeft(find.byKey(_panel)).dy;
      final first = tester.getTopLeft(find.byKey(_report1)).dy;
      final second = tester.getTopLeft(find.byKey(_report2)).dy;
      expect(first, greaterThan(panel));
      expect(second, greaterThan(first));
    });
  });

  group('canvas', () {
    for (final brightness in Brightness.values) {
      testWidgets('is grounded on the diagnostic canvas ($brightness)',
          (tester) async {
        setSize(tester, wide);
        await tester.pumpWidget(wrap(brightness: brightness));

        final ground = tester.widget<ColoredBox>(find
            .ancestor(
              of: find.byKey(_flagged),
              matching: find.byType(ColoredBox),
            )
            .first);
        expect(ground.color, diagnosticCanvasGround);
      });
    }

    testWidgets('reads the dark theme even in light mode', (tester) async {
      setSize(tester, wide);
      await tester.pumpWidget(wrap());

      final context = tester.element(find.byKey(_flagged));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(context.colors.textSecondary, AppColorsData.dark.textSecondary);
    });

    testWidgets('the flagged image takes two thirds, beside the others',
        (tester) async {
      setSize(tester, wide);
      await tester.pumpWidget(wrap());

      final flagged = tester.getRect(find.byKey(_flagged));
      final other = tester.getRect(find.byKey(_other1));
      expect(other.left, greaterThan(flagged.right));
      expect(flagged.width / other.width, closeTo(2, 0.1));
    });

    testWidgets('the other images stack in their third', (tester) async {
      setSize(tester, wide);
      await tester.pumpWidget(wrap());

      final first = tester.getRect(find.byKey(_other1));
      final second = tester.getRect(find.byKey(_other2));
      expect(second.top, greaterThan(first.bottom));
      expect(second.left, first.left);
    });

    testWidgets('with no other images the flagged one fills the canvas',
        (tester) async {
      setSize(tester, wide);
      await tester.pumpWidget(wrap(otherImages: const []));

      final flagged = tester.getRect(find.byKey(_flagged));
      final canvas = tester.getRect(find
          .ancestor(of: find.byKey(_flagged), matching: find.byType(ColoredBox))
          .first);
      expect(flagged.width, closeTo(canvas.width - 2 * AppSpacing.sm, 0.5));
    });
  });

  group('breakpoints', () {
    testWidgets('from twoPaneMinWidth the details sit beside the canvas',
        (tester) async {
      setSize(tester, wide);
      await tester.pumpWidget(wrap());

      final flagged = tester.getRect(find.byKey(_flagged));
      final panel = tester.getRect(find.byKey(_panel));
      expect(panel.left, greaterThan(flagged.right));
      expect(panel.width,
          closeTo(AppLayout.panelMaxWidth - 2 * AppSpacing.lg, 0.5));
    });

    testWidgets('below twoPaneMinWidth the details sit below the canvas',
        (tester) async {
      setSize(tester, narrow);
      await tester.pumpWidget(wrap());

      final flagged = tester.getRect(find.byKey(_flagged));
      final panel = tester.getRect(find.byKey(_panel));
      expect(panel.top, greaterThan(flagged.bottom));
    });

    testWidgets('narrow: the canvas keeps 45% of the height', (tester) async {
      setSize(tester, narrow);
      await tester.pumpWidget(wrap());

      final canvas = tester.getRect(find
          .ancestor(of: find.byKey(_flagged), matching: find.byType(ColoredBox))
          .first);
      final body = tester.getRect(find.byType(LayoutBuilder).first);
      expect(canvas.height, closeTo(body.height * 0.45, 0.5));
    });

    testWidgets('the app bar shows at every tier', (tester) async {
      for (final size in [narrow, wide, const Size(1600, 900)]) {
        setSize(tester, size);
        await tester.pumpWidget(wrap());
        expect(find.byType(AppBar), findsOneWidget, reason: '$size');
      }
    });
  });

  testWidgets('200% text lays out at a phone width', (tester) async {
    setSize(tester, narrow);
    await tester.pumpWidget(wrap(textScale: 2.0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('200% text lays out at twoPaneMinWidth', (tester) async {
    setSize(tester, wide);
    await tester.pumpWidget(wrap(textScale: 2.0));
    expect(tester.takeException(), isNull);
  });
}
