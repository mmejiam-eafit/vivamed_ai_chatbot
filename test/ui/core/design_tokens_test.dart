import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// Contract tests for the `ThemeExtension` mechanism and `buildAppTheme` —
/// see design_tokens.md §10.2, §10.4, §10.5.
///
/// Both failures these guard against are silent: a missing elevation step
/// falls back to whichever field was left to double for it, and a broken
/// `ColorScheme.onError` only shows up if something actually reads
/// `Theme.of(context).colorScheme.error`/`.onError` — nothing does yet, so a
/// regression here would not surface anywhere else in the suite.
void main() {
  group('AppColorsData.dark elevation ladder (§10.4)', () {
    test('all four steps are present and match the specified hex', () {
      expect(AppColorsData.dark.surfacePage, const Color(0xFF0E141B));
      expect(AppColorsData.dark.surface, const Color(0xFF151C25));
      expect(AppColorsData.dark.surfaceRaised, const Color(0xFF1C242F));
      expect(AppColorsData.dark.surfaceOverlay, const Color(0xFF232C38));
    });

    test('every step is a distinct color — none doubles for another', () {
      final steps = <Color>{
        AppColorsData.dark.surfacePage,
        AppColorsData.dark.surface,
        AppColorsData.dark.surfaceRaised,
        AppColorsData.dark.surfaceOverlay,
      };
      expect(steps, hasLength(4));
    });

    test('surfaceSubdued no longer overloads a ladder step', () {
      // Regression guard: surfaceSubdued used to hold surfaceRaised's value
      // (#1C242F) because there was nowhere else to put it. It now aliases
      // the darkest ladder step instead, which is its own, separate field.
      expect(AppColorsData.dark.surfaceSubdued, AppColorsData.dark.surfacePage);
      expect(
        AppColorsData.dark.surfaceSubdued,
        isNot(AppColorsData.dark.surfaceRaised),
      );
    });

    test('light mode has no separate elevation concept — aliases surface',
        () {
      expect(AppColorsData.light.surfaceRaised, AppColorsData.light.surface);
      expect(AppColorsData.light.surfaceOverlay, AppColorsData.light.surface);
    });
  });

  group('AppColorsData.light.border meaningful-border floor (D-016)', () {
    test('border reuses gray500, not the old decorative-only gray300', () {
      expect(AppColorsData.light.border, const Color(0xFF7D7D7D));
    });

    test('border clears the 3:1 floor against both page and surface', () {
      double contrastRatio(Color a, Color b) {
        final la = a.computeLuminance();
        final lb = b.computeLuminance();
        final lighter = la > lb ? la : lb;
        final darker = la > lb ? lb : la;
        return (lighter + 0.05) / (darker + 0.05);
      }

      expect(
        contrastRatio(
          AppColorsData.light.border,
          AppColorsData.light.surfacePage,
        ),
        greaterThanOrEqualTo(3.0),
      );
      expect(
        contrastRatio(AppColorsData.light.border, AppColorsData.light.surface),
        greaterThanOrEqualTo(3.0),
      );
    });

    test('the deprecated AppColors.border alias did not drift from it', () {
      // Regression guard: the two are independent literals, not one
      // delegating to the other, so a copy-paste fix to only one of them
      // would otherwise go uncaught.
      // ignore: deprecated_member_use_from_same_package
      expect(AppColors.border, AppColorsData.light.border);
    });
  });

  group('buildAppTheme colorScheme.onError (§10.5)', () {
    test('dark mode resolves to a genuinely dark-toned color', () {
      // Regression guard: this used to resolve to textPrimary, which is
      // light-toned in dark mode (#E4E8ED on #FF9A93 measures 1.66:1). It
      // now resolves to surfacePage, the darkest confirmed dark-mode value.
      final theme = buildAppTheme(Brightness.dark);
      expect(theme.colorScheme.onError, AppColorsData.dark.surfacePage);
      expect(theme.colorScheme.error, AppColorsData.dark.statusError);
    });

    test('light mode is unchanged — still resolves to textOnBrand', () {
      final theme = buildAppTheme(Brightness.light);
      expect(theme.colorScheme.onError, AppColorsData.light.textOnBrand);
      expect(theme.colorScheme.error, AppColorsData.light.statusError);
    });
  });

  group('buildAppTheme appBarTheme.titleTextStyle (gap 11)', () {
    test('uses headingMd, not the platform default', () {
      // Regression guard: with no titleTextStyle set, AppBar titles fell
      // back to Flutter's own Typography (Roboto) — buildAppTheme() sets no
      // textTheme, so nothing else intercepted it.
      final theme = buildAppTheme();
      final style = theme.appBarTheme.titleTextStyle!;
      expect(style.fontFamily, AppTypography.headingMd.fontFamily);
      expect(style.fontWeight, AppTypography.headingMd.fontWeight);
      expect(style.fontSize, AppTypography.headingMd.fontSize);
    });

    test('color matches textOnBrand in both modes', () {
      final light = buildAppTheme(Brightness.light);
      expect(
        light.appBarTheme.titleTextStyle!.color,
        AppColorsData.light.textOnBrand,
      );
      final dark = buildAppTheme(Brightness.dark);
      expect(
        dark.appBarTheme.titleTextStyle!.color,
        AppColorsData.dark.textOnBrand,
      );
    });
  });
}
