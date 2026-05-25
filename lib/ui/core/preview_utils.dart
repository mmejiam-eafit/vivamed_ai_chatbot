import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// Shared wrapper for all widget previews.
/// Provides MaterialApp + theme + centered Scaffold body.
Widget previewWrapper(Widget child) => MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: Center(child: child)),
    );

/// Full-bleed wrapper for organism previews that need to fill available space.
Widget previewWrapperFull(Widget child) => MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: child),
    );
