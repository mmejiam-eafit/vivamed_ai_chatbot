import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/primary_destinations.dart';

// Each destination page's own tests cover the taps that navigate away (Chat,
// Studies, Settings from every page that mounts the nav). These cover what
// only the shared helper decides.
void main() {
  /// A root route, then a second route whose button calls the helper.
  Future<void> pumpSecondRoute(
    WidgetTester tester,
    void Function(BuildContext context) onTap,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                const Text('root'),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        body: TextButton(
                          onPressed: () => onTap(context),
                          child: const Text('go'),
                        ),
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('a tap on the current destination does nothing',
      (tester) async {
    await pumpSecondRoute(
      tester,
      (context) => openPrimaryDestination(context, 1, current: 1),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('go'), findsOneWidget);
  });

  testWidgets('Home pops back to the root route', (tester) async {
    await pumpSecondRoute(
      tester,
      (context) => openPrimaryDestination(context, 0),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('go'), findsNothing);
    expect(find.text('root'), findsOneWidget);
  });

  testWidgets('an index past the last destination throws', (tester) async {
    late BuildContext captured;
    await pumpSecondRoute(tester, (context) => captured = context);
    await tester.tap(find.text('go'));

    expect(
      () => openPrimaryDestination(captured, 99),
      throwsA(isA<ArgumentError>()),
    );
  });
}
