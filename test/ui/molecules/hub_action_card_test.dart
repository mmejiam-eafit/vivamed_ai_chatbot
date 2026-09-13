import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/hub_action_card.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: Center(child: child)),
      );

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders icon, title, and description', (tester) async {
    await tester.pumpWidget(wrap(HubActionCard(
      icon: Icons.upload_file,
      title: 'Upload a study',
      description: 'Analyze a new DICOM study',
      onTap: () {},
    )));

    expect(find.byIcon(Icons.upload_file), findsOneWidget);
    expect(find.text('Upload a study'), findsOneWidget);
    expect(find.text('Analyze a new DICOM study'), findsOneWidget);
  });

  // ── onTap ──────────────────────────────────────────────────────────────────

  testWidgets('onTap fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(HubActionCard(
      icon: Icons.upload_file,
      title: 'Upload a study',
      description: 'Analyze a new DICOM study',
      onTap: () => called = true,
    )));

    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(called, isTrue);
  });

  // ── Focus ring (DL §8.4) ───────────────────────────────────────────────

  testWidgets('focus ring is transparent when not focused', (tester) async {
    await tester.pumpWidget(wrap(HubActionCard(
      icon: Icons.upload_file,
      title: 'Upload a study',
      description: 'Analyze a new DICOM study',
      onTap: () {},
    )));

    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ).first);
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, Colors.transparent);
  });

  testWidgets('shows a visible focus ring when focused', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(wrap(HubActionCard(
      icon: Icons.upload_file,
      title: 'Upload a study',
      description: 'Analyze a new DICOM study',
      onTap: () {},
      focusNode: focusNode,
    )));
    focusNode.requestFocus();
    await tester.pump();

    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ).first);
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, AppColorsData.light.borderFocused);
  });

  // ── Hover (gap 23 convention) ────────────────────────────────────────────

  testWidgets('hover tints textPrimary at hoverOverlayOpacity', (tester) async {
    await tester.pumpWidget(wrap(HubActionCard(
      icon: Icons.upload_file,
      title: 'Upload a study',
      description: 'Analyze a new DICOM study',
      onTap: () {},
    )));

    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      AppColorsData.light.textPrimary
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  // ── Dark theme ─────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(wrap(
      HubActionCard(
        icon: Icons.upload_file,
        title: 'Upload a study',
        description: 'Analyze a new DICOM study',
        onTap: () {},
      ),
      brightness: Brightness.dark,
    ));

    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      AppColorsData.dark.textPrimary
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );

    final title = tester.widget<Text>(find.text('Upload a study'));
    expect(title.style?.color, AppColorsData.dark.textPrimary);
  });
}
