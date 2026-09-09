import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_logo.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

void main() {
  Widget wrap(Widget child, [Brightness brightness = Brightness.light]) =>
      MaterialApp(
        theme: buildAppTheme(brightness),
        home: Scaffold(body: child),
      );

  SvgAssetLoader loaderOf(WidgetTester tester) =>
      (tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader)
          as SvgAssetLoader;

  testWidgets('full variant loads logo-full.svg', (tester) async {
    await tester.pumpWidget(wrap(const AppLogo()));
    expect(loaderOf(tester).assetName, 'assets/brand/logo-full.svg');
  });

  testWidgets('mark variant loads logo-mark.svg', (tester) async {
    await tester
        .pumpWidget(wrap(const AppLogo(variant: AppLogoVariant.mark)));
    expect(loaderOf(tester).assetName, 'assets/brand/logo-mark.svg');
  });

  testWidgets('defaults to a semantic label of "RadAsk"', (tester) async {
    await tester.pumpWidget(wrap(const AppLogo()));
    final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(picture.semanticsLabel, 'RadAsk');
  });

  testWidgets('reflects a custom semanticLabel', (tester) async {
    await tester.pumpWidget(
        wrap(const AppLogo(semanticLabel: 'RadAsk, back to home')));
    final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(picture.semanticsLabel, 'RadAsk, back to home');
  });

  testWidgets('defaults to size 32.0', (tester) async {
    await tester.pumpWidget(wrap(const AppLogo()));
    final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(picture.height, 32.0);
  });

  testWidgets('reflects a custom size', (tester) async {
    await tester.pumpWidget(wrap(const AppLogo(size: 64.0)));
    final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(picture.height, 64.0);
  });

  testWidgets('loads the same asset regardless of theme brightness',
      (tester) async {
    await tester.pumpWidget(wrap(const AppLogo(), Brightness.dark));
    expect(loaderOf(tester).assetName, 'assets/brand/logo-full.svg');
  });
}
