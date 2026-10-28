import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/review_status_chip.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: Center(child: child)),
      );

  const labels = {
    ReviewStatus.pending: 'Needs review',
    ReviewStatus.decided: 'Processing',
    ReviewStatus.applied: 'Applied',
  };

  ({Color background, Color foreground}) pairFor(
    AppColorsData colors,
    ReviewStatus status,
  ) =>
      switch (status) {
        ReviewStatus.pending => (
            background: colors.statusWarningSubdued,
            foreground: colors.statusWarning,
          ),
        ReviewStatus.decided => (
            background: colors.statusInfoSubdued,
            foreground: colors.statusInfo,
          ),
        ReviewStatus.applied => (
            background: colors.statusSuccessSubdued,
            foreground: colors.statusSuccess,
          ),
      };

  for (final status in ReviewStatus.values) {
    group(status.name, () {
      testWidgets('shows its label', (tester) async {
        await tester.pumpWidget(wrap(ReviewStatusChip(status: status)));
        expect(find.text(labels[status]!), findsOneWidget);
      });

      testWidgets('shows its icon', (tester) async {
        await tester.pumpWidget(wrap(ReviewStatusChip(status: status)));
        expect(find.byIcon(ReviewStatusChip.iconFor(status)), findsOneWidget);
      });

      for (final brightness in Brightness.values) {
        testWidgets('uses its status pair ($brightness)', (tester) async {
          await tester.pumpWidget(
            wrap(ReviewStatusChip(status: status), brightness: brightness),
          );
          final colors = brightness == Brightness.light
              ? AppColorsData.light
              : AppColorsData.dark;
          final pair = pairFor(colors, status);

          final container = tester.widget<Container>(find.byType(Container));
          final decoration = container.decoration! as BoxDecoration;
          expect(decoration.color, pair.background);
          final text = tester.widget<Text>(find.text(labels[status]!));
          expect(text.style?.color, pair.foreground);
          final icon = tester.widget<Icon>(find.byType(Icon));
          expect(icon.color, pair.foreground);
        });
      }
    });
  }

  test('every status has an icon of a different shape', () {
    final icons = ReviewStatus.values.map(ReviewStatusChip.iconFor).toSet();
    expect(icons, hasLength(ReviewStatus.values.length));
  });

  testWidgets('the label is labelMd, at the 12px floor', (tester) async {
    await tester.pumpWidget(
      wrap(const ReviewStatusChip(status: ReviewStatus.pending)),
    );
    final text = tester.widget<Text>(find.text('Needs review'));
    expect(text.style?.fontSize, AppTypography.labelMd.fontSize);
  });

  testWidgets('wraps instead of overflowing in a narrow column',
      (tester) async {
    await tester.pumpWidget(wrap(const SizedBox(
      width: 60,
      child: ReviewStatusChip(status: ReviewStatus.pending),
    )));
    expect(tester.takeException(), isNull);
  });
}
