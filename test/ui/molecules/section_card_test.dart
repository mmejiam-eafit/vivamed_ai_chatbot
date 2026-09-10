import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/section_card.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: child),
      );

  testWidgets('renders the title', (tester) async {
    await tester.pumpWidget(wrap(
      const SectionCard(title: 'Account', child: Text('content')),
    ));
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('renders the child', (tester) async {
    await tester.pumpWidget(wrap(
      const SectionCard(title: 'Account', child: Text('account-content')),
    ));
    expect(find.text('account-content'), findsOneWidget);
  });

  testWidgets('title uses headingSm and textPrimary', (tester) async {
    await tester.pumpWidget(wrap(
      const SectionCard(title: 'Account', child: Text('content')),
    ));
    final title = tester.widget<Text>(find.text('Account'));
    expect(title.style?.fontSize, AppTypography.headingSm.fontSize);
    expect(title.style?.color, AppColorsData.light.textPrimary);
  });

  testWidgets('card is a raised surface: surface fill, card radius, card shadow',
      (tester) async {
    await tester.pumpWidget(wrap(
      const SectionCard(title: 'Account', child: Text('content')),
    ));
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColorsData.light.surface);
    expect(decoration.borderRadius, AppRadius.borderCard);
    expect(decoration.boxShadow, AppElevation.card);
  });

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(wrap(
      const SectionCard(title: 'Account', child: Text('content')),
      brightness: Brightness.dark,
    ));
    final title = tester.widget<Text>(find.text('Account'));
    expect(title.style?.color, AppColorsData.dark.textPrimary);
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColorsData.dark.surface);
  });
}
