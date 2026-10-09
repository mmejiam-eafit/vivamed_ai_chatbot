import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/app.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/organisms/chat_message_list.dart';

/// Helpers shared by the per-tier `app_flow_*_scenarios.dart` files. Every one
/// of them is tier-independent -- anything that differs by tier (how to reach
/// another page, what chrome is on screen) stays in the tier's own file.

/// True on a phone or tablet (a real device or an emulator), where the screen
/// is the tier under test and must not be overridden.
bool get isMobileDevice => Platform.isAndroid || Platform.isIOS;

/// The screen's logical size as the app will see it, readable while tests are
/// still being declared (the device reports its metrics before `main()` runs).
Size get deviceLogicalSize {
  final view = ui.PlatformDispatcher.instance.views.first;
  return view.physicalSize / view.devicePixelRatio;
}

/// Pins the window to [size] at a 1.0 device pixel ratio, so the tier under
/// test is the one the scenario names rather than whatever the host window
/// happens to be (the Linux runner defaults to 1280x720). Does nothing on a
/// phone or tablet: there the device's own screen is what is being tested.
void pinWindow(WidgetTester tester, Size size) {
  if (isMobileDevice) return;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Launches the real app, signs in and lands on Home Hub, walking onboarding
/// first if this machine hasn't completed it.
Future<void> signInToHub(WidgetTester tester) async {
  final themeController = await ThemeController.load();
  await tester.pumpWidget(
    ProviderScope(child: App(themeController: themeController)),
  );
  await tester.pumpAndSettle();

  // Not find.text('Sign In') -- LoginPage has both a heading and the
  // button reading exactly that (confirmed by login_page_test.dart's own
  // findsWidgets assertion for it). LoginPage has exactly one AppButton.
  await tester.tap(find.byType(AppButton));
  await tester.pumpAndSettle();

  // Real on-disk shared_preferences persists has_completed_onboarding
  // across runs on this machine -- so this run may land on Onboarding
  // (first run) or go straight to Home Hub (already onboarded). Handle
  // both rather than assuming one. The Hub's own content is the signal, not
  // a 'Home' title: that title only exists below the wide tier.
  if (find.text('Upload a study').evaluate().isEmpty) {
    // Onboarding: walk to the last slide, then Get Started.
    while (tester.widget<AppButton>(find.byType(AppButton)).label !=
        'Get Started') {
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
  }

  expect(find.text('Upload a study'), findsOneWidget);
}

/// The Scrollable inside the chat message list -- not
/// `find.byType(Scrollable).first`, which at the wide tier is the
/// conversation drawer's own ListView (it comes first in the tree).
Finder messageListScrollable() => find
    .descendant(
      of: find.byType(ChatMessageList),
      matching: find.byType(Scrollable),
    )
    .first;

/// Scrolls [target] into view and lets the layout catch up, so that a tap that
/// follows aims at where it ended up.
///
/// `scrollUntilVisible` finishes with `Scrollable.ensureVisible`, which jumps
/// the list but pumps no frame, and `tester.tap` reads render positions as of
/// the last layout. A lazy list builds an item before it is on screen, so on a
/// short screen the target can be found while still below the viewport, then
/// jumped into view, and the tap lands where it used to be (on the chat input,
/// at 960x600). Measured: the chip moved 58px between the scroll returning and
/// the next frame there, and 0px at the other sizes -- which is why this only
/// failed at one of them. Defaults to the chat message list.
Future<void> scrollIntoView(
  WidgetTester tester,
  Finder target, {
  Finder? scrollable,
}) async {
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: scrollable ?? messageListScrollable(),
  );
  await tester.pumpAndSettle();
}
