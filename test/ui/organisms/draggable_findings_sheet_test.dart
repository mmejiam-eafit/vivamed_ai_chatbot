import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/draggable_findings_sheet.dart';

void main() {
  // bottomSheet, not body: DraggableScrollableSheet is built to float over
  // a Scaffold's Stack-positioned overlay slot, not to fill a tightly-bounded
  // body -- placing it as body in an earlier draft of this test produced a
  // sheet that never actually resized.
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomSheet: DraggableFindingsSheet(
            availableHeight: 800,
            child: child,
          ),
        ),
      );

  testWidgets('renders the child', (tester) async {
    await tester.pumpWidget(wrap(const Text('findings-content')));
    expect(find.text('findings-content'), findsOneWidget);
  });

  testWidgets('is a DraggableScrollableSheet with the documented size range',
      (tester) async {
    await tester.pumpWidget(wrap(const Text('findings-content')));
    final sheet = tester.widget<DraggableScrollableSheet>(
      find.byType(DraggableScrollableSheet),
    );
    expect(sheet.initialChildSize, DraggableFindingsSheet.initialSize);
    expect(sheet.minChildSize, DraggableFindingsSheet.minSize);
    expect(sheet.maxChildSize, DraggableFindingsSheet.maxSize);
  });

  Size visibleSheetSize(WidgetTester tester) => tester.getSize(
        find
            .descendant(
              of: find.byType(DraggableScrollableSheet),
              matching: find.byType(Container),
            )
            .first,
      );

  testWidgets('dragging the handle resizes the sheet', (tester) async {
    // Measures the decorated Container the builder returns, not the sheet
    // widget itself (its own outer box always fills the space Scaffold
    // gives it -- the *visible* sheet is however much of that its content
    // actually occupies) or its child (a bare Text sizes to its own content
    // regardless of how much room it's given).
    await tester.pumpWidget(wrap(const Text('findings-content')));
    await tester.pumpAndSettle();
    final before = visibleSheetSize(tester).height;

    // Dragging the handle's own connected SingleChildScrollView upward is
    // what actually resizes a DraggableScrollableSheet -- confirmed against
    // the Flutter SDK source: resizing goes through a real, attached
    // ScrollPosition's overscroll, not a size a widget can be told directly.
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();

    final after = visibleSheetSize(tester).height;
    expect(after, greaterThan(before));
  });

  testWidgets('does not exceed maxSize when dragged far past it',
      (tester) async {
    await tester.pumpWidget(wrap(const Text('findings-content')));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -10000),
    );
    await tester.pumpAndSettle();

    // maxSize is 0.9 of the sheet's reference height (the 600px test
    // window here) -- an unbounded drag must still land short of the full
    // window, not just short of some arbitrarily large number.
    expect(visibleSheetSize(tester).height, lessThan(600));
  });

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(wrap(
      const Text('findings-content'),
      brightness: Brightness.dark,
    ));
    final container = tester.widget<Container>(find
        .descendant(
          of: find.byType(DraggableScrollableSheet),
          matching: find.byType(Container),
        )
        .first);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColorsData.dark.surface);
  });

  testWidgets('child fills the sheet\'s width whatever it holds',
      (tester) async {
    // A bare ColoredBox takes the smallest size its constraints allow, so it
    // shows what the sheet hands its child (Text sizes itself).
    await tester.pumpWidget(
      wrap(const ColoredBox(key: Key('child'), color: Colors.red)),
    );

    // The sheet's own width (Material 3 caps a bottom sheet at 640 on a wide
    // screen), not the screen's.
    final sheet = tester.getSize(find.byType(DraggableScrollableSheet));
    final child = tester.getSize(find.byKey(const Key('child')));
    expect(child.width, sheet.width);
    expect(child.height, greaterThan(0));
  });
}
