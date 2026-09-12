import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// Shared wrapper for all widget previews.
/// Provides ProviderScope + MaterialApp + theme + centered Scaffold body.
/// Every preview gets a ProviderScope, not just pages' -- most never read
/// from it, but it's free, and it means a page preview never needs its own
/// bespoke wrapper.
Widget previewWrapper(Widget child) => ProviderScope(
      child: MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: Center(child: child)),
      ),
    );

/// Full-bleed wrapper for organism previews that need to fill available space.
Widget previewWrapperFull(Widget child) => ProviderScope(
      child: MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      ),
    );
