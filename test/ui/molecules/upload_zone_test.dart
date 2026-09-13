import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/upload_zone.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: Center(child: child)),
      );

  // ── Status content ─────────────────────────────────────────────────────

  testWidgets('idle: shows upload icon and the default prompt', (tester) async {
    await tester.pumpWidget(wrap(
      UploadZone(status: UploadZoneStatus.idle, onTap: () {}),
    ));

    expect(find.byIcon(Icons.upload_file), findsOneWidget);
    expect(find.text('Tap to choose a study (DICOM files)'), findsOneWidget);
  });

  testWidgets('idle with files selected: shows a count instead of the prompt',
      (tester) async {
    await tester.pumpWidget(wrap(UploadZone(
      status: UploadZoneStatus.idle,
      selectedFileNames: const ['1.dcm', '2.dcm', '3.dcm'],
      onTap: () {},
    )));

    expect(find.text('3 files selected'), findsOneWidget);
    expect(find.text('Tap to choose a study (DICOM files)'), findsNothing);
  });

  testWidgets('idle with exactly one file selected: singular count', (tester) async {
    await tester.pumpWidget(wrap(UploadZone(
      status: UploadZoneStatus.idle,
      selectedFileNames: const ['1.dcm'],
      onTap: () {},
    )));

    expect(find.text('1 file selected'), findsOneWidget);
  });

  testWidgets('idle with an empty selection list: shows the default prompt',
      (tester) async {
    await tester.pumpWidget(wrap(UploadZone(
      status: UploadZoneStatus.idle,
      selectedFileNames: const [],
      onTap: () {},
    )));

    expect(find.text('Tap to choose a study (DICOM files)'), findsOneWidget);
  });

  testWidgets('uploading: shows a loading indicator and label, no upload icon',
      (tester) async {
    await tester.pumpWidget(wrap(
      UploadZone(status: UploadZoneStatus.uploading, onTap: () {}),
    ));

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
    expect(find.byIcon(Icons.upload_file), findsNothing);
    expect(find.text('Uploading…'), findsOneWidget);
  });

  testWidgets('analyzing: shows a loading indicator and label', (tester) async {
    await tester.pumpWidget(wrap(
      UploadZone(status: UploadZoneStatus.analyzing, onTap: () {}),
    ));

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
    expect(find.text('Analyzing…'), findsOneWidget);
  });

  // ── onTap ──────────────────────────────────────────────────────────────────

  testWidgets('onTap fires when idle', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(
      UploadZone(status: UploadZoneStatus.idle, onTap: () => called = true),
    ));

    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(called, isTrue);
  });

  testWidgets('onTap does not fire while uploading', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(
      UploadZone(status: UploadZoneStatus.uploading, onTap: () => called = true),
    ));

    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(inkWell.onTap, isNull);
    expect(called, isFalse);
  });

  testWidgets('onTap does not fire while analyzing', (tester) async {
    await tester.pumpWidget(wrap(
      UploadZone(status: UploadZoneStatus.analyzing, onTap: () {}),
    ));

    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(inkWell.onTap, isNull);
  });

  // ── Focus ring (DL §8.4) ───────────────────────────────────────────────

  testWidgets('focus ring is transparent when not focused', (tester) async {
    await tester.pumpWidget(wrap(
      UploadZone(status: UploadZoneStatus.idle, onTap: () {}),
    ));

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
    await tester.pumpWidget(wrap(UploadZone(
      status: UploadZoneStatus.idle,
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
    await tester.pumpWidget(wrap(
      UploadZone(status: UploadZoneStatus.idle, onTap: () {}),
    ));

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
      UploadZone(status: UploadZoneStatus.idle, onTap: () {}),
      brightness: Brightness.dark,
    ));

    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      AppColorsData.dark.textPrimary
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );

    final label =
        tester.widget<Text>(find.text('Tap to choose a study (DICOM files)'));
    expect(label.style?.color, AppColorsData.dark.textSecondary);
  });
}
