import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// A labeled tab strip paired with its content views. Wraps
/// `DefaultTabController` + `TabBar` + `TabBarView` — every color it needs
/// resolves from `context.colors` internally, so callers never handle theme.
class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.tabs, required this.tabViews})
      : assert(
          tabs.length == tabViews.length,
          'AppTabBar requires one view per tab',
        );

  final List<String> tabs;
  final List<Widget> tabViews;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          TabBar(
            indicatorColor: colors.interactivePrimary,
            labelColor: colors.interactivePrimary,
            unselectedLabelColor: colors.textSecondary,
            tabs: [for (final label in tabs) Tab(text: label)],
          ),
          Expanded(child: TabBarView(children: tabViews)),
        ],
      ),
    );
  }
}
