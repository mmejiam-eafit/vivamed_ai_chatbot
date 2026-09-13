import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';
import 'package:radiologist_helper/ui/molecules/upload_zone.dart';
import 'package:radiologist_helper/ui/organisms/status_bar.dart';
import 'package:radiologist_helper/ui/templates/upload_template.dart';

void main() {
  group('UploadTemplate', () {
    UploadTemplate buildTemplate({StatusBar? statusBar}) => UploadTemplate(
          appBar: AppBar(title: const Text('Upload a Study')),
          uploadZone: UploadZone(status: UploadZoneStatus.idle, onTap: () {}),
          actionButton: AppButton(label: 'Upload', onPressed: () {}),
          statusBar: statusBar,
        );

    testWidgets('renders appBar slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );
      expect(find.text('Upload a Study'), findsOneWidget);
    });

    testWidgets('renders uploadZone slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );
      expect(find.byType(UploadZone), findsOneWidget);
    });

    testWidgets('renders actionButton slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
    });

    testWidgets('statusBar is absent when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );
      expect(find.byType(StatusBar), findsNothing);
    });

    testWidgets('renders statusBar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: buildTemplate(
            statusBar: const StatusBar(
              message: 'Study processed successfully',
              variant: StatusBannerVariant.success,
            ),
          ),
        ),
      );
      expect(find.byType(StatusBar), findsOneWidget);
      expect(find.text('Study processed successfully'), findsOneWidget);
    });

    testWidgets('uses surfacePage scaffold background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.light.surfacePage);
    });

    testWidgets('resolves against the dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          home: buildTemplate(),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.dark.surfacePage);
    });
  });
}
