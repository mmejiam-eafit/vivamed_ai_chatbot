import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_text_field.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  testWidgets('renders a TextField', (tester) async {
    await tester.pumpWidget(wrap(const AppTextField()));
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('reflects hintText', (tester) async {
    await tester.pumpWidget(wrap(const AppTextField(hintText: 'Search…')));
    expect(find.text('Search…'), findsOneWidget);
  });

  testWidgets('controller text is readable after input', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(wrap(AppTextField(controller: controller)));
    await tester.enterText(find.byType(TextField), 'hello');
    expect(controller.text, 'hello');
  });

  testWidgets('onChanged fires on input', (tester) async {
    String? changed;
    await tester.pumpWidget(wrap(AppTextField(onChanged: (v) => changed = v)));
    await tester.enterText(find.byType(TextField), 'hi');
    expect(changed, 'hi');
  });

  testWidgets('onSubmitted fires on action', (tester) async {
    String? submitted;
    await tester.pumpWidget(wrap(AppTextField(
      onSubmitted: (v) => submitted = v,
      textInputAction: TextInputAction.done,
    )));
    await tester.enterText(find.byType(TextField), 'world');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(submitted, 'world');
  });

  testWidgets('reflects obscureText', (tester) async {
    await tester.pumpWidget(wrap(const AppTextField(obscureText: true)));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
  });

  testWidgets('clamps maxLines to 1 when obscureText is true', (tester) async {
    await tester.pumpWidget(
        wrap(const AppTextField(obscureText: true, maxLines: 5)));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 1);
  });

  testWidgets('reflects maxLines when obscureText is false', (tester) async {
    await tester.pumpWidget(wrap(const AppTextField(maxLines: 4)));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 4);
  });

  testWidgets('reflects enabled false', (tester) async {
    await tester.pumpWidget(wrap(const AppTextField(enabled: false)));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });

  testWidgets('shows prefixIcon when provided', (tester) async {
    await tester.pumpWidget(wrap(
      const AppTextField(prefixIcon: Icon(Icons.search)),
    ));
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('shows suffixIcon when provided', (tester) async {
    await tester.pumpWidget(wrap(
      const AppTextField(suffixIcon: Icon(Icons.clear)),
    ));
    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('reflects keyboardType', (tester) async {
    await tester.pumpWidget(
        wrap(const AppTextField(keyboardType: TextInputType.emailAddress)));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.keyboardType, TextInputType.emailAddress);
  });
}
