import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/image_thumbnail.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  const fullFields = [
    StudyMetadataField(label: 'Patient', value: 'Anonymous-7812'),
    StudyMetadataField(label: 'Date', value: '2026-05-01'),
    StudyMetadataField(label: 'Modality', value: 'CT'),
    StudyMetadataField(label: 'Study UID', value: '1.2.840'),
  ];

  // ── Content rendering ──────────────────────────────────────────────────────

  testWidgets('renders title text', (tester) async {
    await tester.pumpWidget(wrap(const StudyInfoCard(
      title: 'Chest CT',
      fields: [],
    )));
    expect(find.text('Chest CT'), findsOneWidget);
  });

  testWidgets('renders metadata field label and value', (tester) async {
    await tester.pumpWidget(wrap(const StudyInfoCard(
      title: 'Study',
      fields: [StudyMetadataField(label: 'Modality', value: 'CT')],
    )));
    expect(find.text('Modality'), findsOneWidget);
    expect(find.text('CT'), findsOneWidget);
  });

  testWidgets('renders all provided metadata fields', (tester) async {
    await tester.pumpWidget(wrap(const StudyInfoCard(
      title: 'Study',
      fields: fullFields,
    )));
    expect(find.byType(MetadataField), findsNWidgets(fullFields.length));
  });

  testWidgets('shows ImageThumbnail when thumbnailUrl is provided', (tester) async {
    await tester.pumpWidget(wrap(const StudyInfoCard(
      title: 'Study',
      fields: [],
      thumbnailUrl: 'https://picsum.photos/80/80',
    )));
    expect(find.byType(ImageThumbnail), findsOneWidget);
  });

  testWidgets('hides ImageThumbnail when thumbnailUrl is null', (tester) async {
    await tester.pumpWidget(wrap(const StudyInfoCard(
      title: 'Study',
      fields: [],
    )));
    expect(find.byType(ImageThumbnail), findsNothing);
  });

  testWidgets('shows badge text when thumbnailBadge is provided', (tester) async {
    await tester.pumpWidget(wrap(const StudyInfoCard(
      title: 'Study',
      fields: [],
      thumbnailUrl: 'https://picsum.photos/80/80',
      thumbnailBadge: '5',
    )));
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('renders no MetadataField when fields list is empty', (tester) async {
    await tester.pumpWidget(wrap(const StudyInfoCard(
      title: 'Study',
      fields: [],
    )));
    expect(find.byType(MetadataField), findsNothing);
  });

  // ── Overflow prevention ────────────────────────────────────────────────────

  testWidgets('does not overflow with thumbnail in tight constrained height',
      (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;

    await tester.pumpWidget(wrap(const SizedBox(
      width: 360,
      height: 150, // deliberately shorter than natural content height (~220px)
      child: StudyInfoCard(
        title: 'Chest CT — Posterior-Anterior',
        fields: fullFields,
        thumbnailUrl: 'https://picsum.photos/80/80',
        thumbnailBadge: '3',
      ),
    )));

    FlutterError.onError = prev;
    expect(
      errors.where((e) => e.toString().contains('overflowed')),
      isEmpty,
      reason: 'StudyInfoCard must scroll rather than overflow',
    );
  });

  testWidgets('does not overflow without thumbnail in tight constrained height',
      (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;

    await tester.pumpWidget(wrap(const SizedBox(
      width: 360,
      height: 100, // shorter than natural content height (~180px)
      child: StudyInfoCard(
        title: 'Chest X-Ray',
        fields: fullFields,
      ),
    )));

    FlutterError.onError = prev;
    expect(
      errors.where((e) => e.toString().contains('overflowed')),
      isEmpty,
      reason: 'StudyInfoCard must scroll rather than overflow',
    );
  });

  testWidgets('does not overflow with single field in tight constrained height',
      (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;

    await tester.pumpWidget(wrap(const SizedBox(
      width: 360,
      height: 40, // shorter than natural content height (~100px)
      child: StudyInfoCard(
        title: 'Abdominal CT',
        fields: [StudyMetadataField(label: 'Modality', value: 'CT')],
      ),
    )));

    FlutterError.onError = prev;
    expect(
      errors.where((e) => e.toString().contains('overflowed')),
      isEmpty,
      reason: 'StudyInfoCard must scroll rather than overflow',
    );
  });
}
