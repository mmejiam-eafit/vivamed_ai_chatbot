import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/image_thumbnail.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  testWidgets('renders without throwing', (tester) async {
    await tester.pumpWidget(wrap(
      const ImageThumbnail(url: 'https://example.com/img.png'),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders an Image widget', (tester) async {
    await tester.pumpWidget(wrap(
      const ImageThumbnail(url: 'https://example.com/img.png'),
    ));
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('uses ClipRRect for rounded corners', (tester) async {
    await tester.pumpWidget(wrap(
      const ImageThumbnail(url: 'https://example.com/img.png'),
    ));
    expect(find.byType(ClipRRect), findsOneWidget);
  });

  testWidgets('default dimensions are 80×80', (tester) async {
    await tester.pumpWidget(wrap(
      const ImageThumbnail(url: 'https://example.com/img.png'),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 80.0);
    expect(image.height, 80.0);
  });

  testWidgets('reflects custom width and height', (tester) async {
    await tester.pumpWidget(wrap(
      const ImageThumbnail(
        url: 'https://example.com/img.png',
        width: 120.0,
        height: 90.0,
      ),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 120.0);
    expect(image.height, 90.0);
  });

  testWidgets('badge is shown when badgeLabel provided', (tester) async {
    await tester.pumpWidget(wrap(
      const ImageThumbnail(
        url: 'https://example.com/img.png',
        badgeLabel: '5',
      ),
    ));
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('no badge when badgeLabel is null', (tester) async {
    await tester.pumpWidget(wrap(
      const ImageThumbnail(url: 'https://example.com/img.png'),
    ));
    expect(find.byType(Positioned), findsNothing);
  });

  testWidgets('onTap fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(ImageThumbnail(
      url: 'https://example.com/img.png',
      onTap: () => called = true,
    )));
    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    expect(called, isTrue);
  });

  // ── Focus ring (DL §8.4) ───────────────────────────────────────────────

  testWidgets('focus ring is transparent when not focused', (tester) async {
    await tester.pumpWidget(wrap(ImageThumbnail(
      url: 'https://example.com/img.png',
      onTap: () {},
    )));
    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ));
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, Colors.transparent);
  });

  testWidgets('shows a visible focus ring when focused', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(wrap(ImageThumbnail(
      url: 'https://example.com/img.png',
      onTap: () {},
      focusNode: focusNode,
    )));
    focusNode.requestFocus();
    await tester.pump();

    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ));
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, AppColorsData.light.borderFocused);
  });

  // ── Hover (gap 23) ─────────────────────────────────────────────────────────

  testWidgets('hover tints textPrimary at hoverOverlayOpacity', (tester) async {
    await tester.pumpWidget(wrap(
      const ImageThumbnail(url: 'https://example.com/img.png'),
    ));
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      AppColorsData.light.textPrimary
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  testWidgets('hover color resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(
        body: ImageThumbnail(url: 'https://example.com/img.png'),
      ),
    ));
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      AppColorsData.dark.textPrimary
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });
}
