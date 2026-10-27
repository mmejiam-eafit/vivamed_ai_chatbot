import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/captioned_image.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.dark}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: SizedBox(width: 200, height: 300, child: child)),
      );

  const image = CaptionedImage(
    url: 'https://example.com/img.png',
    caption: 'Header PA · dataset Frontal',
  );

  testWidgets('shows the caption', (tester) async {
    await tester.pumpWidget(wrap(image));
    expect(find.text('Header PA · dataset Frontal'), findsOneWidget);
  });

  testWidgets('shows the whole image, never cropped (DL D-020)',
      (tester) async {
    await tester.pumpWidget(wrap(image));
    final picture = tester.widget<Image>(find.byType(Image));
    expect(picture.fit, BoxFit.contain);
  });

  testWidgets('the caption sits below the image, not over it',
      (tester) async {
    await tester.pumpWidget(wrap(image));
    final imageBottom = tester.getBottomLeft(find.byType(Image)).dy;
    final captionTop =
        tester.getTopLeft(find.text('Header PA · dataset Frontal')).dy;
    expect(captionTop, greaterThanOrEqualTo(imageBottom));
  });

  testWidgets('the caption is labelMd in textSecondary', (tester) async {
    await tester.pumpWidget(wrap(image));
    final text = tester.widget<Text>(find.text('Header PA · dataset Frontal'));
    expect(text.style?.fontSize, AppTypography.labelMd.fontSize);
    expect(text.style?.color, AppColorsData.dark.textSecondary);
  });

  testWidgets('a long caption wraps rather than truncating', (tester) async {
    await tester.pumpWidget(wrap(const CaptionedImage(
      url: 'https://example.com/img.png',
      caption: 'Flagged · header Left lateral (LL) · dataset Frontal',
    )));
    final text = tester.widget<Text>(find.textContaining('Flagged'));
    expect(text.maxLines, isNull);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });
}
