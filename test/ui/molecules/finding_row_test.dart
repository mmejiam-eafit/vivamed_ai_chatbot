import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/finding_row.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  const labels = {
    SeverityLevel.normal: 'NORMAL',
    SeverityLevel.mild: 'MILD',
    SeverityLevel.moderate: 'MODERATE',
    SeverityLevel.critical: 'CRITICAL',
  };

  // ── Name ───────────────────────────────────────────────────────────────────

  testWidgets('finding name is shown', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Consolidation',
      severity: SeverityLevel.moderate,
    )));
    expect(find.text('Consolidation'), findsOneWidget);
  });

  // ── Severity labels ────────────────────────────────────────────────────────

  for (final entry in labels.entries) {
    testWidgets('${entry.key}: shows ${entry.value} label', (tester) async {
      await tester.pumpWidget(wrap(FindingRow(
        name: 'Finding',
        severity: entry.key,
      )));
      expect(find.text(entry.value), findsOneWidget);
    });
  }

  // ── Expand icon ────────────────────────────────────────────────────────────

  testWidgets('isExpanded: false shows expand_more icon', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.mild,
    )));
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    expect(find.byIcon(Icons.expand_less), findsNothing);
  });

  testWidgets('isExpanded: true shows expand_less icon', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.mild,
      isExpanded: true,
    )));
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsNothing);
  });

  // ── onTap callback ─────────────────────────────────────────────────────────

  testWidgets('onTap fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(FindingRow(
      name: 'Finding',
      severity: SeverityLevel.critical,
      onTap: () => called = true,
    )));
    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    expect(called, isTrue);
  });

  // ── SeverityDot ────────────────────────────────────────────────────────────

  testWidgets('contains a SeverityDot', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.normal,
    )));
    expect(find.byType(SeverityDot), findsOneWidget);
  });

  // ── Expand (DL §4.6: the full name must stay reachable) ───────────────────

  testWidgets('collapsed: name clamps to one line', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'A very long finding name that would otherwise overflow the row',
      severity: SeverityLevel.mild,
    )));
    final text = tester.widget<Text>(find.textContaining('A very long'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('expanded: name is no longer clamped', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'A very long finding name that would otherwise overflow the row',
      severity: SeverityLevel.mild,
      isExpanded: true,
    )));
    final text = tester.widget<Text>(find.textContaining('A very long'));
    expect(text.maxLines, isNull);
  });

  // ── Typography ─────────────────────────────────────────────────────────────

  testWidgets('severity label renders at or above the 12px clinical floor',
      (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.mild,
    )));
    final text = tester.widget<Text>(find.text('MILD'));
    expect(text.style?.fontSize, greaterThanOrEqualTo(12.0));
  });

  // ── Alarm vs quiet (DL §5.2, §5.3) ────────────────────────────────────────

  // The two ranks are distinguished by weight, not size: labelMd is w600,
  // bodySm is w400, and both sit at the 12px clinical floor (DL §4.4, §4.5).
  FontWeight? labelWeight(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style?.fontWeight;

  // Checks for the alarm chip's own fill specifically — not FocusRing's
  // Container, which always has a BoxDecoration (border, transparent or
  // not) but never a `color`.
  bool hasFilledChip(WidgetTester tester) => tester
      .widgetList<Container>(find.byType(Container))
      .any((c) => c.decoration is BoxDecoration &&
          (c.decoration! as BoxDecoration).color != null);

  testWidgets('critical carries alarm treatment by default', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.critical,
    )));
    expect(labelWeight(tester, 'CRITICAL'), FontWeight.w600);
    expect(hasFilledChip(tester), isTrue);
  });

  testWidgets('critical goes quiet when the list holds the alarm',
      (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.critical,
      isAlarm: false,
    )));
    expect(labelWeight(tester, 'CRITICAL'), FontWeight.w400);
    expect(hasFilledChip(tester), isFalse);
  });

  for (final level in [SeverityLevel.normal, SeverityLevel.mild]) {
    testWidgets('$level is never alarm, even when asked', (tester) async {
      await tester.pumpWidget(wrap(FindingRow(
        name: 'Finding',
        severity: level,
        isAlarm: true,
      )));
      final label = level == SeverityLevel.normal ? 'NORMAL' : 'MILD';
      expect(labelWeight(tester, label), FontWeight.w400);
      expect(hasFilledChip(tester), isFalse);
      // Demoted, not erased — the label and the distinct dot silhouette both
      // survive, because severity may never rest on hue alone (DL §3.6).
      expect(find.text(label), findsOneWidget);
      expect(find.byType(SeverityDot), findsOneWidget);
    });
  }

  // ── Density (DL §7.1: this is a scanning surface, so it stays dense) ──────

  testWidgets('padding is dense (md/sm), not generous', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.mild,
    )));
    // Scoped inside InkWell specifically — FocusRing's own Container also
    // composes an internal Padding (its focus-ring offset), which sits
    // outside the InkWell and would otherwise be found first.
    final padding = tester.widget<Padding>(
      find.descendant(of: find.byType(InkWell), matching: find.byType(Padding)).first,
    );
    expect(
      padding.padding,
      const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    );
  });

  // ── Focus ring (DL §8.4) ───────────────────────────────────────────────

  testWidgets('focus ring: transparent, then visible once focused',
      (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(wrap(FindingRow(
      name: 'Finding',
      severity: SeverityLevel.mild,
      onTap: () {},
      focusNode: focusNode,
    )));

    BoxDecoration ringDecoration() => tester
        .widget<Container>(find.ancestor(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        ))
        .decoration! as BoxDecoration;

    expect(ringDecoration().border!.top.color, Colors.transparent);

    focusNode.requestFocus();
    await tester.pump();

    expect(ringDecoration().border!.top.color, AppColorsData.light.borderFocused);
  });

  testWidgets('with no onTap, requesting focus does not show a ring',
      (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(wrap(FindingRow(
      name: 'Finding',
      severity: SeverityLevel.mild,
      focusNode: focusNode,
    )));
    focusNode.requestFocus();
    await tester.pump();

    final ringContainer = tester.widget<Container>(find.ancestor(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ));
    final decoration = ringContainer.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, Colors.transparent);
  });

  // ── Hover (gap 23) ─────────────────────────────────────────────────────────

  testWidgets('hover tints textPrimary at hoverOverlayOpacity', (tester) async {
    await tester.pumpWidget(wrap(const FindingRow(
      name: 'Finding',
      severity: SeverityLevel.mild,
    )));
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
        body: FindingRow(name: 'Finding', severity: SeverityLevel.mild),
      ),
    ));
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.hoverColor,
      AppColorsData.dark.textPrimary
          .withValues(alpha: AppInteraction.hoverOverlayOpacity),
    );
  });

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(
        body: FindingRow(name: 'Finding', severity: SeverityLevel.critical),
      ),
    ));
    final text = tester.widget<Text>(find.text('CRITICAL'));
    expect(text.style?.color, SeverityData.dark.critical);
    final icon = tester.widget<Icon>(find.byIcon(Icons.expand_more));
    expect(icon.color, AppColorsData.dark.icon);
  });
}
