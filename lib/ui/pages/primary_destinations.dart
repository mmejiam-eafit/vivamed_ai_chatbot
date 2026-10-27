import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';

/// Opens primary destination [index] -- the order `AppNavBar` and
/// `PrimaryNavDrawer` list them in. Every page that mounts either one routes
/// its taps through here, so the index-to-page mapping lives in one place
/// instead of one copy per page.
///
/// [current] is the calling page's own destination, and a tap on it does
/// nothing. Drill-down pages (Study Review, Similar Cases) pass none, so every
/// destination navigates away. Home pops back to the root route; the others
/// replace the current route, keeping the stack flat.
///
/// Not a widget: page-level navigation shared by the pages, which are the only
/// level allowed to navigate.
void openPrimaryDestination(BuildContext context, int index, {int? current}) {
  if (index == current) return;
  final navigator = Navigator.of(context);
  final Widget page;
  switch (index) {
    case 0:
      navigator.popUntil((route) => route.isFirst);
      return;
    case 1:
      page = const ChatPage();
    case 2:
      page = const CaseListPage();
    case 3:
      page = const SettingsPage();
    default:
      throw ArgumentError.value(index, 'index', 'No primary destination');
  }
  navigator.pushReplacement(MaterialPageRoute(builder: (_) => page));
}
