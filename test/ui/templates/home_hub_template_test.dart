import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/hub_action_card.dart';
import 'package:radiologist_helper/ui/templates/home_hub_template.dart';

void main() {
  group('HomeHubTemplate', () {
    HomeHubTemplate buildTemplate() => HomeHubTemplate(
          appBar: AppBar(title: const Text('Home')),
          uploadCard: HubActionCard(
            icon: Icons.upload_file,
            title: 'Upload a study',
            description: 'Analyze a new DICOM study',
            onTap: () {},
          ),
          viewStudiesCard: HubActionCard(
            icon: Icons.folder_outlined,
            title: 'View studies',
            description: 'Browse existing studies',
            onTap: () {},
          ),
          chatCard: HubActionCard(
            icon: Icons.chat_bubble_outline,
            title: 'Chat',
            description: 'Ask about any case',
            onTap: () {},
          ),
        );

    testWidgets('renders appBar slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('renders all three cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );
      expect(find.text('Upload a study'), findsOneWidget);
      expect(find.text('View studies'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
    });

    // ── Compact: stacked column (< mediumMinWidth) ────────────────────────

    testWidgets('stacks cards below mediumMinWidth', (tester) async {
      const width = AppLayout.mediumMinWidth - 1;
      tester.view.physicalSize = const Size(width * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );

      // The row branch wraps each card in Expanded; the column branch
      // doesn't use Expanded at all -- an unambiguous signal either way.
      expect(find.byType(Expanded), findsNothing);
    });

    // ── Medium and up: a single row ────────────────────────────────────────

    testWidgets('lays cards out in a row at mediumMinWidth and up',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: buildTemplate()),
      );

      expect(find.byType(Expanded), findsNWidgets(3));
    });

    // ── Dark theme ─────────────────────────────────────────────────────────

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
