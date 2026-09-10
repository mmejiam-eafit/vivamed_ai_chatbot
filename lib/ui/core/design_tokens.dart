import 'package:flutter/material.dart';

// ============================================================================
// Design Tokens — Radiologist Helper Chatbot
// ============================================================================
// Base palette from: https://colorhunt.co/palette/0c2b4e1a3d641d546cf4f4f4
//
//   #0C2B4E  Deep Navy      — primary brand
//   #1A3D64  Medium Navy    — secondary brand
//   #1D546C  Teal Blue      — accent / interactive
//   #F4F4F4  Off-White      — light ground
//
// All public tokens are named by PURPOSE, not by color.
// Raw hex values live in `_Palette` (library-private).
// ============================================================================

// ── Raw palette (library-private) ───────────────────────────────────────────
// Never reference `_Palette` in widget code. Use `AppColors` instead.

abstract final class _Palette {
  // Brand
  static const Color deepNavy = Color(0xFF0C2B4E);
  static const Color mediumNavy = Color(0xFF1A3D64);
  static const Color tealBlue = Color(0xFF1D546C);
  static const Color offWhite = Color(0xFFF4F4F4);

  // Diagnostic image ground. Mode-exempt, so it sits here with the other
  // mode-invariant values rather than in the dark block below. Specified by
  // design_tokens.md §10.4 and §2.10 — not a new color.
  static const Color diagnosticCanvas = Color(0xFF0A0C0E);

  // Deep Navy scale
  static const Color deepNavy900 = Color(0xFF061625);
  // ignore: unused_field
  static const Color deepNavy700 = Color(0xFF123A68);
  // ignore: unused_field
  static const Color deepNavy600 = Color(0xFF184A82);
  // ignore: unused_field
  static const Color deepNavy100 = Color(0xFFD4DEE9);
  static const Color deepNavy50 = Color(0xFFECF0F5);

  // Medium Navy scale
  static const Color mediumNavy800 = Color(0xFF0F2640);
  // ignore: unused_field
  static const Color mediumNavy600 = Color(0xFF245486);
  // ignore: unused_field
  static const Color mediumNavy400 = Color(0xFF4A7AAE);
  // ignore: unused_field
  static const Color mediumNavy100 = Color(0xFFD6E1ED);
  static const Color mediumNavy50 = Color(0xFFEDF1F7);

  // Teal Blue scale
  static const Color tealBlue800 = Color(0xFF0F3545);
  static const Color tealBlue600 = Color(0xFF267390);
  static const Color tealBlue400 = Color(0xFF3D95B8);
  static const Color tealBlue300 = Color(0xFF6DB3CE);
  // ignore: unused_field
  static const Color tealBlue100 = Color(0xFFCDE5EE);
  static const Color tealBlue50 = Color(0xFFE9F3F7);

  // Neutral scale
  static const Color gray900 = Color(0xFF1A1A1A);
  // ignore: unused_field
  static const Color gray800 = Color(0xFF2E2E2E);
  static const Color gray700 = Color(0xFF4A4A4A);
  static const Color gray600 = Color(0xFF636363);
  static const Color gray500 = Color(0xFF7D7D7D);
  static const Color gray400 = Color(0xFFA0A0A0);
  static const Color gray300 = Color(0xFFC4C4C4);
  static const Color gray200 = Color(0xFFDCDCDC);
  static const Color gray100 = Color(0xFFEEEEEE);
  static const Color white = Color(0xFFFFFFFF);

  // Status — foregrounds corrected to clear WCAG AA (design_tokens.md §2.8,
  // DL §8.7). statusSuccess/normal, statusWarning/moderate and
  // statusError/critical each share one value by design (same row in §2.8).
  static const Color green700 = Color(0xFF276A43);
  static const Color green50 = Color(0xFFD9F0E3);
  static const Color amber700 = Color(0xFF855B06);
  static const Color amber50 = Color(0xFFFFF4D6);
  static const Color red700 = Color(0xFFA42121);
  static const Color red50 = Color(0xFFFFE0E0);
  static const Color blue700 = Color(0xFF02639E);
  static const Color blue50 = Color(0xFFDCEEF9);

  // gray500 is also shared by interactiveDisabledForeground and
  // AppScrollbar.thumbHoverColor (both WCAG-exempt), so textMuted's fix needed
  // its own constant rather than mutating gray500 in place.
  static const Color gray550 = Color(0xFF6E6E6E);

  // tealBlue400 is also shared by borderFocused/interactiveAccent, which only
  // need the 3:1 UI floor and already clear it — so statusInfo and
  // textLinkHover get their own constants instead of mutating tealBlue400.
  static const Color tealBlue750 = Color(0xFF23566A);
  static const Color tealBlue700 = Color(0xFF275F75);

  // ── Dark palette (design_tokens.md §10.4) ──────────────────────────────
  // Official — ratified, computed, verified, not a proposal. §10.4 specifies
  // a four-step lightness ladder; all four steps get their own constant so
  // none has to double for another (surfaceRaised previously overloaded the
  // name "darkSurfaceSubdued" and surfaceOverlay had no field at all).
  static const Color darkSurfacePage = Color(0xFF0E141B);
  static const Color darkSurface = Color(0xFF151C25);
  static const Color darkSurfaceRaised = Color(0xFF1C242F);
  static const Color darkSurfaceOverlay = Color(0xFF232C38);
  static const Color darkSurfaceBrand = Color(0xFF16273D);
  static const Color darkSurfaceBrandSecondary = Color(0xFF1B3049);
  static const Color darkTextPrimary = Color(0xFFE4E8ED);
  static const Color darkTextSecondary = Color(0xFFB4BCC6);
  static const Color darkTextTertiary = Color(0xFF939CA8);
  static const Color darkTextMuted = Color(0xFF8B95A1);
  // Same value as tealBlue300 above — reuse it rather than duplicate the hex.
  static const Color darkTextLink = tealBlue300;
  static const Color darkBorder = Color(0xFF5E6B7A);
  static const Color darkBorderSubdued = Color(0xFF2A3442);
  static const Color darkInteractivePrimary = Color(0xFF4FA3C4);
  static const Color darkNormal = Color(0xFF7FD1A0);
  static const Color darkNormalBg = Color(0xFF14301F);
  static const Color darkMild = Color(0xFF8ECDF2);
  static const Color darkMildBg = Color(0xFF12293A);
  static const Color darkModerate = Color(0xFFF0C070);
  static const Color darkModerateBg = Color(0xFF3A2A0F);
  static const Color darkCritical = Color(0xFFFF9A93);
  static const Color darkCriticalBg = Color(0xFF421D1D);
}

// ============================================================================
// Semantic Colors
// ============================================================================
// Every token answers: "What is this color FOR?" — not "What color IS it?"

abstract final class AppColors {
  // ── Surfaces ────────────────────────────────────────────────────────────
  @Deprecated('Use context.colors.surfacePage')
  static const Color surfacePage = _Palette.offWhite;
  @Deprecated('Use context.colors.surface')
  static const Color surface = _Palette.white;
  @Deprecated('Use context.colors.surfaceSubdued')
  static const Color surfaceSubdued = _Palette.gray100;
  @Deprecated('Use context.colors.surfaceBrand')
  static const Color surfaceBrand = _Palette.deepNavy;
  @Deprecated('Use context.colors.surfaceBrandSecondary')
  static const Color surfaceBrandSecondary = _Palette.mediumNavy;
  @Deprecated('Use context.colors.surfaceAccent')
  static const Color surfaceAccent = _Palette.tealBlue50;
  @Deprecated('Use context.colors.surfaceBrandSubdued')
  static const Color surfaceBrandSubdued = _Palette.deepNavy50;
  @Deprecated('Use context.colors.surfaceBrandSecondarySubdued')
  static const Color surfaceBrandSecondarySubdued = _Palette.mediumNavy50;

  // ── Text ────────────────────────────────────────────────────────────────
  @Deprecated('Use context.colors.textPrimary')
  static const Color textPrimary = _Palette.gray900;
  @Deprecated('Use context.colors.textSecondary')
  static const Color textSecondary = _Palette.gray700;
  @Deprecated('Use context.colors.textTertiary')
  static const Color textTertiary = _Palette.gray600;
  @Deprecated('Use context.colors.textPlaceholder')
  static const Color textPlaceholder = _Palette.gray400;
  @Deprecated('Use context.colors.textDisabled')
  static const Color textDisabled = _Palette.gray400;
  @Deprecated('Use context.colors.textMuted')
  static const Color textMuted = _Palette.gray550;
  @Deprecated('Use context.colors.textOnBrand')
  static const Color textOnBrand = _Palette.offWhite;
  @Deprecated('Use context.colors.textOnAccent')
  static const Color textOnAccent = _Palette.tealBlue800;
  @Deprecated('Use context.colors.textOnBrandSubdued')
  static const Color textOnBrandSubdued = _Palette.deepNavy900;
  @Deprecated('Use context.colors.textOnBrandSecondarySubdued')
  static const Color textOnBrandSecondarySubdued = _Palette.mediumNavy800;
  @Deprecated('Use context.colors.textLink')
  static const Color textLink = _Palette.tealBlue600;
  @Deprecated('Use context.colors.textLinkHover')
  static const Color textLinkHover = _Palette.tealBlue700;
  @Deprecated('Use context.colors.textLinkVisited')
  static const Color textLinkVisited = _Palette.tealBlue800;

  // ── Icons ───────────────────────────────────────────────────────────────
  @Deprecated('Use context.colors.icon')
  static const Color icon = _Palette.gray600;
  @Deprecated('Use context.colors.iconOnBrand')
  static const Color iconOnBrand = _Palette.offWhite;
  @Deprecated('Use context.colors.iconAccent')
  static const Color iconAccent = _Palette.tealBlue;
  @Deprecated('Use context.colors.iconDisabled')
  static const Color iconDisabled = _Palette.gray400;

  // ── Borders ─────────────────────────────────────────────────────────────
  @Deprecated('Use context.colors.border')
  static const Color border = _Palette.gray500;
  @Deprecated('Use context.colors.borderSubdued')
  static const Color borderSubdued = _Palette.gray200;
  @Deprecated('Use context.colors.borderFocused')
  static const Color borderFocused = _Palette.tealBlue400;
  @Deprecated('Use context.colors.borderSelected')
  static const Color borderSelected = _Palette.tealBlue;

  // ── Interactive ─────────────────────────────────────────────────────────
  @Deprecated('Use context.colors.interactivePrimary')
  static const Color interactivePrimary = _Palette.tealBlue;
  @Deprecated('Use context.colors.interactivePrimaryForeground')
  static const Color interactivePrimaryForeground = _Palette.offWhite;
  @Deprecated('Use context.colors.interactiveSecondary')
  static const Color interactiveSecondary = _Palette.white;
  @Deprecated('Use context.colors.interactiveSecondaryForeground')
  static const Color interactiveSecondaryForeground = _Palette.tealBlue;
  @Deprecated('Use context.colors.interactiveHover')
  static const Color interactiveHover = _Palette.tealBlue600;
  @Deprecated('Use context.colors.interactiveAccent')
  static const Color interactiveAccent = _Palette.tealBlue400;
  @Deprecated('Use context.colors.interactiveDisabled')
  static const Color interactiveDisabled = _Palette.gray200;
  @Deprecated('Use context.colors.interactiveDisabledForeground')
  static const Color interactiveDisabledForeground = _Palette.gray500;

  // ── Status ──────────────────────────────────────────────────────────────
  // App-level operational status. NOT for clinical severity (use SeverityTokens).
  @Deprecated('Use context.colors.statusSuccess')
  static const Color statusSuccess = _Palette.green700;
  @Deprecated('Use context.colors.statusSuccessSubdued')
  static const Color statusSuccessSubdued = _Palette.green50;
  @Deprecated('Use context.colors.statusWarning')
  static const Color statusWarning = _Palette.amber700;
  @Deprecated('Use context.colors.statusWarningSubdued')
  static const Color statusWarningSubdued = _Palette.amber50;
  @Deprecated('Use context.colors.statusError')
  static const Color statusError = _Palette.red700;
  @Deprecated('Use context.colors.statusErrorSubdued')
  static const Color statusErrorSubdued = _Palette.red50;
  @Deprecated('Use context.colors.statusInfo')
  static const Color statusInfo = _Palette.tealBlue750;
  @Deprecated('Use context.colors.statusInfoSubdued')
  static const Color statusInfoSubdued = _Palette.tealBlue50;

  // ── Brand reference ─────────────────────────────────────────────────────
  // Exposed for rare cases where the raw brand color is needed semantically
  // (e.g., logo rendering, brand-specific illustrations).
  // Mode-invariant (design_tokens.md §2.7) — not part of AppColorsData.

  /// Primary brand color — prefer surfaceBrand for backgrounds.
  static const Color brandPrimary = _Palette.deepNavy;

  /// Secondary brand color — prefer surfaceBrandSecondary for backgrounds.
  static const Color brandSecondary = _Palette.mediumNavy;

  /// Accent brand color — prefer interactivePrimary for buttons.
  static const Color brandAccent = _Palette.tealBlue;

  /// Brand light ground — prefer surfacePage for scaffold backgrounds.
  static const Color brandLight = _Palette.offWhite;
}

// ============================================================================
// Theme extension — AppColorsData (design_tokens.md §10.2, §10.4)
// ============================================================================
// Immutable color set, one instance per brightness. `AppColors.*` above stays
// as a `@Deprecated` alias to `AppColorsData.light` so unmigrated call sites
// keep compiling and rendering identically; migrated widgets read
// `context.colors.*` instead, which resolves to whichever brightness is active.
//
// A handful of fields have no independently-ratified dark value in §10.4
// (surfaceSubdued, surfaceAccent, surfaceBrandSubdued/SecondarySubdued,
// textOnAccent, textOnBrandSubdued/SecondarySubdued, textLinkHover,
// textLinkVisited, textPlaceholder/textDisabled/interactiveDisabledForeground,
// interactivePrimaryForeground). Each is derived below from an already-
// specified dark value via the same equality/construction relationship §2.8
// documents for its light counterpart — never an invented hex. See the
// implementation notes for the exact mapping.
//
// surfaceRaised and surfaceOverlay are the two remaining steps of §10.4's
// four-step elevation ladder (surfacePage and surface are the first two) —
// independently ratified in dark mode; light mode has no separate concept
// (elevation is shadow-based there, §6), so both alias `surface`.
class AppColorsData extends ThemeExtension<AppColorsData> {
  const AppColorsData({
    required this.surfacePage,
    required this.surface,
    required this.surfaceSubdued,
    required this.surfaceRaised,
    required this.surfaceOverlay,
    required this.surfaceBrand,
    required this.surfaceBrandSecondary,
    required this.surfaceAccent,
    required this.surfaceBrandSubdued,
    required this.surfaceBrandSecondarySubdued,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textPlaceholder,
    required this.textDisabled,
    required this.textMuted,
    required this.textOnBrand,
    required this.textOnAccent,
    required this.textOnBrandSubdued,
    required this.textOnBrandSecondarySubdued,
    required this.textLink,
    required this.textLinkHover,
    required this.textLinkVisited,
    required this.icon,
    required this.iconOnBrand,
    required this.iconAccent,
    required this.iconDisabled,
    required this.border,
    required this.borderSubdued,
    required this.borderFocused,
    required this.borderSelected,
    required this.interactivePrimary,
    required this.interactivePrimaryForeground,
    required this.interactiveSecondary,
    required this.interactiveSecondaryForeground,
    required this.interactiveHover,
    required this.interactiveAccent,
    required this.interactiveDisabled,
    required this.interactiveDisabledForeground,
    required this.statusSuccess,
    required this.statusSuccessSubdued,
    required this.statusWarning,
    required this.statusWarningSubdued,
    required this.statusError,
    required this.statusErrorSubdued,
    required this.statusInfo,
    required this.statusInfoSubdued,
  });

  final Color surfacePage;
  final Color surface;
  final Color surfaceSubdued;
  final Color surfaceRaised;
  final Color surfaceOverlay;
  final Color surfaceBrand;
  final Color surfaceBrandSecondary;
  final Color surfaceAccent;
  final Color surfaceBrandSubdued;
  final Color surfaceBrandSecondarySubdued;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textPlaceholder;
  final Color textDisabled;
  final Color textMuted;
  final Color textOnBrand;
  final Color textOnAccent;
  final Color textOnBrandSubdued;
  final Color textOnBrandSecondarySubdued;
  final Color textLink;
  final Color textLinkHover;
  final Color textLinkVisited;
  final Color icon;
  final Color iconOnBrand;
  final Color iconAccent;
  final Color iconDisabled;
  final Color border;
  final Color borderSubdued;
  final Color borderFocused;
  final Color borderSelected;
  final Color interactivePrimary;
  final Color interactivePrimaryForeground;
  final Color interactiveSecondary;
  final Color interactiveSecondaryForeground;
  final Color interactiveHover;
  final Color interactiveAccent;
  final Color interactiveDisabled;
  final Color interactiveDisabledForeground;
  final Color statusSuccess;
  final Color statusSuccessSubdued;
  final Color statusWarning;
  final Color statusWarningSubdued;
  final Color statusError;
  final Color statusErrorSubdued;
  final Color statusInfo;
  final Color statusInfoSubdued;

  static const AppColorsData light = AppColorsData(
    surfacePage: _Palette.offWhite,
    surface: _Palette.white,
    surfaceSubdued: _Palette.gray100,
    // No separate elevation-ladder concept in light mode — shadow-based (§6).
    surfaceRaised: _Palette.white,
    surfaceOverlay: _Palette.white,
    surfaceBrand: _Palette.deepNavy,
    surfaceBrandSecondary: _Palette.mediumNavy,
    surfaceAccent: _Palette.tealBlue50,
    surfaceBrandSubdued: _Palette.deepNavy50,
    surfaceBrandSecondarySubdued: _Palette.mediumNavy50,
    textPrimary: _Palette.gray900,
    textSecondary: _Palette.gray700,
    textTertiary: _Palette.gray600,
    textPlaceholder: _Palette.gray400,
    textDisabled: _Palette.gray400,
    textMuted: _Palette.gray550,
    textOnBrand: _Palette.offWhite,
    textOnAccent: _Palette.tealBlue800,
    textOnBrandSubdued: _Palette.deepNavy900,
    textOnBrandSecondarySubdued: _Palette.mediumNavy800,
    textLink: _Palette.tealBlue600,
    textLinkHover: _Palette.tealBlue700,
    textLinkVisited: _Palette.tealBlue800,
    icon: _Palette.gray600,
    iconOnBrand: _Palette.offWhite,
    iconAccent: _Palette.tealBlue,
    iconDisabled: _Palette.gray400,
    border: _Palette.gray500,
    borderSubdued: _Palette.gray200,
    borderFocused: _Palette.tealBlue400,
    borderSelected: _Palette.tealBlue,
    interactivePrimary: _Palette.tealBlue,
    interactivePrimaryForeground: _Palette.offWhite,
    interactiveSecondary: _Palette.white,
    interactiveSecondaryForeground: _Palette.tealBlue,
    interactiveHover: _Palette.tealBlue600,
    interactiveAccent: _Palette.tealBlue400,
    interactiveDisabled: _Palette.gray200,
    interactiveDisabledForeground: _Palette.gray500,
    statusSuccess: _Palette.green700,
    statusSuccessSubdued: _Palette.green50,
    statusWarning: _Palette.amber700,
    statusWarningSubdued: _Palette.amber50,
    statusError: _Palette.red700,
    statusErrorSubdued: _Palette.red50,
    statusInfo: _Palette.tealBlue750,
    statusInfoSubdued: _Palette.tealBlue50,
  );

  static const AppColorsData dark = AppColorsData(
    surfacePage: _Palette.darkSurfacePage,
    surface: _Palette.darkSurface,
    // No independent dark spec (§10.4 defines the elevation ladder, not a
    // separate "subdued" tone) — light mode's surfaceSubdued is darker than
    // its surface, so alias to the darkest already-specified tone rather
    // than overload one of the ladder's own steps.
    surfaceSubdued: _Palette.darkSurfacePage,
    surfaceRaised: _Palette.darkSurfaceRaised,
    surfaceOverlay: _Palette.darkSurfaceOverlay,
    surfaceBrand: _Palette.darkSurfaceBrand,
    surfaceBrandSecondary: _Palette.darkSurfaceBrandSecondary,
    // Alias: light surfaceAccent == statusInfoSubdued (both tealBlue50).
    surfaceAccent: _Palette.darkMildBg,
    // Alias: no independent dark spec — reuses the elevated-navy surface.
    surfaceBrandSubdued: _Palette.darkSurfaceBrand,
    surfaceBrandSecondarySubdued: _Palette.darkSurfaceBrandSecondary,
    textPrimary: _Palette.darkTextPrimary,
    textSecondary: _Palette.darkTextSecondary,
    textTertiary: _Palette.darkTextTertiary,
    // WCAG-exempt; no independent dark spec, so reuses textMuted's value.
    textPlaceholder: _Palette.darkTextMuted,
    textDisabled: _Palette.darkTextMuted,
    textMuted: _Palette.darkTextMuted,
    textOnBrand: _Palette.darkTextPrimary,
    // Alias: mirrors light's textOnAccent/textLinkVisited pairing with Info.
    textOnAccent: _Palette.darkMild,
    textOnBrandSubdued: _Palette.darkTextPrimary,
    textOnBrandSecondarySubdued: _Palette.darkTextPrimary,
    textLink: _Palette.darkTextLink,
    // No independent dark hover spec — reuses the resting link value.
    textLinkHover: _Palette.darkTextLink,
    textLinkVisited: _Palette.darkMild,
    icon: _Palette.darkTextTertiary,
    iconOnBrand: _Palette.darkTextPrimary,
    iconAccent: _Palette.darkInteractivePrimary,
    iconDisabled: _Palette.darkTextMuted,
    border: _Palette.darkBorder,
    borderSubdued: _Palette.darkBorderSubdued,
    borderFocused: _Palette.darkTextLink,
    borderSelected: _Palette.darkInteractivePrimary,
    interactivePrimary: _Palette.darkInteractivePrimary,
    // No independent dark spec — darkest ladder step, for contrast against
    // the now-light interactivePrimary fill.
    interactivePrimaryForeground: _Palette.darkSurfacePage,
    interactiveSecondary: _Palette.darkSurface,
    interactiveSecondaryForeground: _Palette.darkInteractivePrimary,
    interactiveHover: _Palette.darkTextLink,
    interactiveAccent: _Palette.darkTextLink,
    interactiveDisabled: _Palette.darkBorderSubdued,
    interactiveDisabledForeground: _Palette.darkTextMuted,
    statusSuccess: _Palette.darkNormal,
    statusSuccessSubdued: _Palette.darkNormalBg,
    statusWarning: _Palette.darkModerate,
    statusWarningSubdued: _Palette.darkModerateBg,
    statusError: _Palette.darkCritical,
    statusErrorSubdued: _Palette.darkCriticalBg,
    // Dark mode deliberately reuses the Mild pair for Info (design_tokens.md §10.4).
    statusInfo: _Palette.darkMild,
    statusInfoSubdued: _Palette.darkMildBg,
  );

  @override
  AppColorsData copyWith({
    Color? surfacePage,
    Color? surface,
    Color? surfaceSubdued,
    Color? surfaceRaised,
    Color? surfaceOverlay,
    Color? surfaceBrand,
    Color? surfaceBrandSecondary,
    Color? surfaceAccent,
    Color? surfaceBrandSubdued,
    Color? surfaceBrandSecondarySubdued,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textPlaceholder,
    Color? textDisabled,
    Color? textMuted,
    Color? textOnBrand,
    Color? textOnAccent,
    Color? textOnBrandSubdued,
    Color? textOnBrandSecondarySubdued,
    Color? textLink,
    Color? textLinkHover,
    Color? textLinkVisited,
    Color? icon,
    Color? iconOnBrand,
    Color? iconAccent,
    Color? iconDisabled,
    Color? border,
    Color? borderSubdued,
    Color? borderFocused,
    Color? borderSelected,
    Color? interactivePrimary,
    Color? interactivePrimaryForeground,
    Color? interactiveSecondary,
    Color? interactiveSecondaryForeground,
    Color? interactiveHover,
    Color? interactiveAccent,
    Color? interactiveDisabled,
    Color? interactiveDisabledForeground,
    Color? statusSuccess,
    Color? statusSuccessSubdued,
    Color? statusWarning,
    Color? statusWarningSubdued,
    Color? statusError,
    Color? statusErrorSubdued,
    Color? statusInfo,
    Color? statusInfoSubdued,
  }) {
    return AppColorsData(
      surfacePage: surfacePage ?? this.surfacePage,
      surface: surface ?? this.surface,
      surfaceSubdued: surfaceSubdued ?? this.surfaceSubdued,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      surfaceBrand: surfaceBrand ?? this.surfaceBrand,
      surfaceBrandSecondary:
          surfaceBrandSecondary ?? this.surfaceBrandSecondary,
      surfaceAccent: surfaceAccent ?? this.surfaceAccent,
      surfaceBrandSubdued: surfaceBrandSubdued ?? this.surfaceBrandSubdued,
      surfaceBrandSecondarySubdued:
          surfaceBrandSecondarySubdued ?? this.surfaceBrandSecondarySubdued,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      textDisabled: textDisabled ?? this.textDisabled,
      textMuted: textMuted ?? this.textMuted,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      textOnBrandSubdued: textOnBrandSubdued ?? this.textOnBrandSubdued,
      textOnBrandSecondarySubdued:
          textOnBrandSecondarySubdued ?? this.textOnBrandSecondarySubdued,
      textLink: textLink ?? this.textLink,
      textLinkHover: textLinkHover ?? this.textLinkHover,
      textLinkVisited: textLinkVisited ?? this.textLinkVisited,
      icon: icon ?? this.icon,
      iconOnBrand: iconOnBrand ?? this.iconOnBrand,
      iconAccent: iconAccent ?? this.iconAccent,
      iconDisabled: iconDisabled ?? this.iconDisabled,
      border: border ?? this.border,
      borderSubdued: borderSubdued ?? this.borderSubdued,
      borderFocused: borderFocused ?? this.borderFocused,
      borderSelected: borderSelected ?? this.borderSelected,
      interactivePrimary: interactivePrimary ?? this.interactivePrimary,
      interactivePrimaryForeground:
          interactivePrimaryForeground ?? this.interactivePrimaryForeground,
      interactiveSecondary: interactiveSecondary ?? this.interactiveSecondary,
      interactiveSecondaryForeground:
          interactiveSecondaryForeground ?? this.interactiveSecondaryForeground,
      interactiveHover: interactiveHover ?? this.interactiveHover,
      interactiveAccent: interactiveAccent ?? this.interactiveAccent,
      interactiveDisabled: interactiveDisabled ?? this.interactiveDisabled,
      interactiveDisabledForeground:
          interactiveDisabledForeground ?? this.interactiveDisabledForeground,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusSuccessSubdued: statusSuccessSubdued ?? this.statusSuccessSubdued,
      statusWarning: statusWarning ?? this.statusWarning,
      statusWarningSubdued: statusWarningSubdued ?? this.statusWarningSubdued,
      statusError: statusError ?? this.statusError,
      statusErrorSubdued: statusErrorSubdued ?? this.statusErrorSubdued,
      statusInfo: statusInfo ?? this.statusInfo,
      statusInfoSubdued: statusInfoSubdued ?? this.statusInfoSubdued,
    );
  }

  @override
  AppColorsData lerp(ThemeExtension<AppColorsData>? other, double t) {
    if (other is! AppColorsData) return this;
    return AppColorsData(
      surfacePage: Color.lerp(surfacePage, other.surfacePage, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubdued: Color.lerp(surfaceSubdued, other.surfaceSubdued, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      surfaceBrand: Color.lerp(surfaceBrand, other.surfaceBrand, t)!,
      surfaceBrandSecondary:
          Color.lerp(surfaceBrandSecondary, other.surfaceBrandSecondary, t)!,
      surfaceAccent: Color.lerp(surfaceAccent, other.surfaceAccent, t)!,
      surfaceBrandSubdued:
          Color.lerp(surfaceBrandSubdued, other.surfaceBrandSubdued, t)!,
      surfaceBrandSecondarySubdued: Color.lerp(
          surfaceBrandSecondarySubdued, other.surfaceBrandSecondarySubdued, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      textOnBrandSubdued:
          Color.lerp(textOnBrandSubdued, other.textOnBrandSubdued, t)!,
      textOnBrandSecondarySubdued: Color.lerp(
          textOnBrandSecondarySubdued, other.textOnBrandSecondarySubdued, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      textLinkHover: Color.lerp(textLinkHover, other.textLinkHover, t)!,
      textLinkVisited: Color.lerp(textLinkVisited, other.textLinkVisited, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      iconOnBrand: Color.lerp(iconOnBrand, other.iconOnBrand, t)!,
      iconAccent: Color.lerp(iconAccent, other.iconAccent, t)!,
      iconDisabled: Color.lerp(iconDisabled, other.iconDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubdued: Color.lerp(borderSubdued, other.borderSubdued, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      borderSelected: Color.lerp(borderSelected, other.borderSelected, t)!,
      interactivePrimary:
          Color.lerp(interactivePrimary, other.interactivePrimary, t)!,
      interactivePrimaryForeground: Color.lerp(
          interactivePrimaryForeground, other.interactivePrimaryForeground, t)!,
      interactiveSecondary:
          Color.lerp(interactiveSecondary, other.interactiveSecondary, t)!,
      interactiveSecondaryForeground: Color.lerp(interactiveSecondaryForeground,
          other.interactiveSecondaryForeground, t)!,
      interactiveHover:
          Color.lerp(interactiveHover, other.interactiveHover, t)!,
      interactiveAccent:
          Color.lerp(interactiveAccent, other.interactiveAccent, t)!,
      interactiveDisabled:
          Color.lerp(interactiveDisabled, other.interactiveDisabled, t)!,
      interactiveDisabledForeground: Color.lerp(interactiveDisabledForeground,
          other.interactiveDisabledForeground, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusSuccessSubdued:
          Color.lerp(statusSuccessSubdued, other.statusSuccessSubdued, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusWarningSubdued:
          Color.lerp(statusWarningSubdued, other.statusWarningSubdued, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      statusErrorSubdued:
          Color.lerp(statusErrorSubdued, other.statusErrorSubdued, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      statusInfoSubdued:
          Color.lerp(statusInfoSubdued, other.statusInfoSubdued, t)!,
    );
  }
}

/// Reads the active brightness's tokens — `context.colors.textPrimary`, etc.
extension AppThemeContext on BuildContext {
  AppColorsData get colors =>
      Theme.of(this).extension<AppColorsData>() ?? AppColorsData.light;
  SeverityData get severity =>
      Theme.of(this).extension<SeverityData>() ?? SeverityData.light;
}

// ============================================================================
// Spacing
// ============================================================================
// Scale values are standard (xs–huge). Size names are appropriate here because
// spacing is inherently a relative-size decision, not a purpose decision — the
// same token can be padding, margin, or gap depending on context.

abstract final class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double huge = 64.0;
}

// ============================================================================
// Border Radius — semantic by component role
// ============================================================================

abstract final class AppRadius {
  // ── Semantic tokens ─────────────────────────────────────────────────────

  /// Inline code blocks, table cells, tiny tags.
  static const double inlineElement = 4.0;

  /// Buttons, chips, small interactive controls.
  static const double button = 8.0;

  /// Standard cards, containers, dialogs.
  static const double card = 12.0;

  /// Large cards, image containers, panels.
  static const double panel = 16.0;

  /// Bottom sheets, modals, large overlays.
  static const double sheet = 24.0;

  /// Text inputs, search bars, fully rounded action buttons.
  static const double input = 999.0;

  // ── Pre-built BorderRadius objects ──────────────────────────────────────

  static final BorderRadius borderInlineElement =
      BorderRadius.circular(inlineElement);
  static final BorderRadius borderButton = BorderRadius.circular(button);
  static final BorderRadius borderCard = BorderRadius.circular(card);
  static final BorderRadius borderPanel = BorderRadius.circular(panel);
  static final BorderRadius borderSheet = BorderRadius.circular(sheet);
  static final BorderRadius borderInput = BorderRadius.circular(input);
}

// ============================================================================
// Elevation / Shadows — semantic by surface role
// ============================================================================

abstract final class AppElevation {
  /// Flat: no shadow. Elements that rely on border or background for separation.
  static const List<BoxShadow> flat = [];

  /// Resting card: default elevated surface at rest (cards, list items).
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Raised interactive: hovered cards, floating action buttons, popovers.
  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Overlay: dialogs, dropdown menus, tooltips.
  static const List<BoxShadow> overlay = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Modal: full-screen modal sheets, image viewers, top-level overlays.
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

// ============================================================================
// Typography
// ============================================================================
// Already semantic: names describe text ROLE (display, heading, body, label,
// caption, mono) not visual properties.

abstract final class AppTypography {
  // ── Font families ─────────────────────────────────────────────────────────
  // Three voices — see design_language.md §4.
  //   Display: structure and authority.
  //   Body:    sustained clinical reading.
  //   Mono:    machine truth — anything a human might transcribe.
  //
  // Measured x-heights (em): Plex Sans 0.516, Inter 0.546, Plex Mono 0.516.
  // Inter's is the largest, so the display scale sits ABOVE the body scale
  // rather than overlapping it — at equal size, Inter would out-measure a
  // heading and invert the hierarchy. This is why headingSm is 18, not 16.
  static const String fontFamilyDisplay = 'IBMPlexSans';
  static const String fontFamilyBody = 'Inter';
  static const String fontFamilyMono = 'IBMPlexMono';

  // ── OpenType features ─────────────────────────────────────────────────────
  // Flutter does not enable these implicitly; an unrequested feature is inert.

  /// For identifiers, measurements, dates, and any numeric column.
  ///
  /// Inter's digits are PROPORTIONAL by default (advance widths 833–1323 per
  /// 2048 em — `1` is far narrower than `0`), so a table of numbers jitters
  /// column to column without `tnum`. `ss02` is Inter's disambiguation set:
  /// it separates `I`/`l`/`1` and slashes the zero.
  ///
  /// Deliberately NOT applied to prose — tabular figures read wrong mid-
  /// sentence, and disambiguated letterforms are a distraction in running text.
  // `FontFeature.stylisticSet(2)` is a factory, not a const constructor, so the
  // raw tag is used to keep these styles compile-time constants.
  static const List<FontFeature> tabularFeatures = <FontFeature>[
    FontFeature.tabularFigures(),
    FontFeature('ss02'),
  ];

  /// Plex Mono is monospaced, so its figures are already tabular (every digit
  /// advances 600/1000 em). Only the slashed zero has to be asked for.
  static const List<FontFeature> monoFeatures = <FontFeature>[
    FontFeature.slashedZero(),
  ];

  // ── Display scale ─────────────────────────────────────────────────────────
  // IBM Plex Sans. Plex needs less negative tracking than a geometric face.

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.29,
    letterSpacing: -0.2,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.1,
  );

  static const TextStyle headingLg = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.36,
  );

  static const TextStyle headingMd = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.40,
  );

  /// 18, not 16 — the smallest heading must still out-measure `bodyLg`.
  static const TextStyle headingSm = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.44,
  );

  // ── Body scale ────────────────────────────────────────────────────────────
  // Inter. Slight negative tracking at 14+ per the typeface's own guidance;
  // neutral at 12 and positive below, where tighter tracking hurts legibility.

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.18,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.57,
    letterSpacing: -0.08,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.67,
  );

  /// Non-clinical metadata only. The 12 px floor applies to any string a
  /// clinician has to read — see design_language.md §4.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0.1,
  );

  // ── Label scale ───────────────────────────────────────────────────────────
  // Plex Sans at w600. Rank is carried by weight here, not size, so these sit
  // at the same sizes as body text by design.

  static const TextStyle labelLg = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 0.4,
  );

  // ── Data ──────────────────────────────────────────────────────────────────

  /// DICOM tags, study UIDs, accession numbers, technical output.
  /// 14, not 13 — Plex Mono's x-height is 6% below JetBrains Mono's, and this
  /// sits inline with `bodyMd`.
  static const TextStyle mono = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFeatures: monoFeatures,
  );

  /// Measurements, dates, and confidence values inside tables and rows —
  /// body voice, but with figures that align in a column.
  static const TextStyle numeric = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.57,
    letterSpacing: -0.08,
    fontFeatures: tabularFeatures,
  );
}

// ============================================================================
// Icon Sizes
// ============================================================================
// A semantic scale so icon sizes are consistent and not scattered as magic
// numbers across widget files.

abstract final class AppIconSize {
  /// Tiny indicator icons inside dense components (12 px).
  static const double xs = 12.0;

  /// Small icons in list rows, chips, badges (16 px).
  static const double sm = 16.0;

  /// Standard content icons: rows, banners, nav items (20 px).
  static const double md = 20.0;

  /// Default icon size for buttons and app bars (24 px).
  static const double lg = 24.0;

  /// Large icons for empty states and illustration spots (32 px).
  static const double xl = 32.0;
}

// ============================================================================
// Chat-specific tokens
// ============================================================================
// Already semantic — updated to reference AppColors semantic layer.

abstract final class ChatTokens {
  // Bubble colors
  static const Color userBubble = AppColors.interactivePrimary;
  static const Color userBubbleText = AppColors.interactivePrimaryForeground;
  static const Color assistantBubble = AppColors.surface;
  static const Color assistantBubbleText = AppColors.textPrimary;
  static const Color assistantBubbleBorder = AppColors.borderSubdued;

  // Input field
  static const Color inputBackground = AppColors.surface;
  static const Color inputBorder = AppColors.border;
  static const Color inputBorderFocused = AppColors.borderFocused;
  static const Color inputPlaceholder = AppColors.textPlaceholder;
  static const Color inputText = AppColors.textPrimary;

  // Misc
  static const Color timestamp = AppColors.textMuted;
  static const Color typingIndicator = AppColors.interactiveAccent;

  // Input focus / selection (wired into buildAppTheme via textSelectionTheme)
  /// Blinking text cursor inside the chat input.
  static const Color inputCursorColor = AppColors.interactivePrimary;

  /// Text selection highlight inside the chat input.
  static const Color inputSelectionColor = AppColors.surfaceAccent;

  /// Input fill color when focused — subtle brand tint.
  static const Color inputFocusedBackground = AppColors.surfaceAccent;
  static const double bubbleRadius = 18.0;
  static const double bubbleMaxWidthFraction = 0.78;
  // Hard cap so bubbles never span the full page on wide desktop screens.
  static const double bubbleMaxAbsoluteWidth = 480.0;

  static const BorderRadius bubbleRadiusUser = BorderRadius.only(
    topLeft: Radius.circular(bubbleRadius),
    topRight: Radius.circular(bubbleRadius),
    bottomLeft: Radius.circular(bubbleRadius),
    bottomRight: Radius.circular(4),
  );

  static const BorderRadius bubbleRadiusAssistant = BorderRadius.only(
    topLeft: Radius.circular(4),
    topRight: Radius.circular(bubbleRadius),
    bottomLeft: Radius.circular(bubbleRadius),
    bottomRight: Radius.circular(bubbleRadius),
  );
}

// ============================================================================
// Navigation tokens
// ============================================================================
// Already semantic — updated to reference AppColors semantic layer.

abstract final class NavigationTokens {
  static const Color appBarBackground = AppColors.surfaceBrand;
  static const Color appBarForeground = AppColors.textOnBrand;
  static const Color drawerBackground = AppColors.surfaceBrandSecondary;
  static const Color drawerForeground = AppColors.textOnBrand;
  static const Color bottomNavBackground = AppColors.surface;
  static const Color bottomNavSelected = AppColors.iconAccent;
  static const Color bottomNavUnselected = AppColors.textMuted;
  // Side navigation (web / desktop sidebar)
  static const Color sideNavBackground = AppColors.surfaceBrandSecondary;
  static const Color sideNavSelected = AppColors.interactivePrimary;
  static const Color sideNavUnselected = AppColors.iconOnBrand;

  /// Hover fill on an unselected sidebar item (on brand-dark background).
  static const Color sideNavHoverColor = _Palette.mediumNavy600;

  /// Border radius applied to each sidebar nav item pill.
  static const double sideNavItemBorderRadius = AppRadius.button;

  // Navigation dimensions
  /// Standard drawer width for mobile slide-over drawer.
  static const double drawerWidth = 280.0;

  /// Persistent sidebar width on web/desktop.
  static const double sideNavWidth = 240.0;

  /// Icon-only collapsed sidebar width.
  static const double sideNavCollapsedWidth = 64.0;

  static const double appBarElevation = 0;
}

// ============================================================================
// Severity tokens (radiology-specific)
// ============================================================================
// Clinical finding severity — NOT app-level status.
// These reference _Palette directly because their meaning is domain-specific
// and deliberately separate from the general-purpose AppColors status tokens.

abstract final class SeverityTokens {
  @Deprecated('Use context.severity.normal')
  static const Color normal = _Palette.green700;
  @Deprecated('Use context.severity.normalBg')
  static const Color normalBg = _Palette.green50;

  @Deprecated('Use context.severity.mild')
  static const Color mild = _Palette.blue700;
  @Deprecated('Use context.severity.mildBg')
  static const Color mildBg = _Palette.blue50;

  @Deprecated('Use context.severity.moderate')
  static const Color moderate = _Palette.amber700;
  @Deprecated('Use context.severity.moderateBg')
  static const Color moderateBg = _Palette.amber50;

  @Deprecated('Use context.severity.critical')
  static const Color critical = _Palette.red700;
  @Deprecated('Use context.severity.criticalBg')
  static const Color criticalBg = _Palette.red50;
}

/// Immutable severity color set, one instance per brightness (design_tokens.md
/// §10.4). `SeverityTokens.*` stays as a `@Deprecated` alias to
/// `SeverityData.light` for unmigrated call sites.
class SeverityData extends ThemeExtension<SeverityData> {
  const SeverityData({
    required this.normal,
    required this.normalBg,
    required this.mild,
    required this.mildBg,
    required this.moderate,
    required this.moderateBg,
    required this.critical,
    required this.criticalBg,
  });

  final Color normal;
  final Color normalBg;
  final Color mild;
  final Color mildBg;
  final Color moderate;
  final Color moderateBg;
  final Color critical;
  final Color criticalBg;

  static const SeverityData light = SeverityData(
    normal: _Palette.green700,
    normalBg: _Palette.green50,
    mild: _Palette.blue700,
    mildBg: _Palette.blue50,
    moderate: _Palette.amber700,
    moderateBg: _Palette.amber50,
    critical: _Palette.red700,
    criticalBg: _Palette.red50,
  );

  static const SeverityData dark = SeverityData(
    normal: _Palette.darkNormal,
    normalBg: _Palette.darkNormalBg,
    mild: _Palette.darkMild,
    mildBg: _Palette.darkMildBg,
    moderate: _Palette.darkModerate,
    moderateBg: _Palette.darkModerateBg,
    critical: _Palette.darkCritical,
    criticalBg: _Palette.darkCriticalBg,
  );

  @override
  SeverityData copyWith({
    Color? normal,
    Color? normalBg,
    Color? mild,
    Color? mildBg,
    Color? moderate,
    Color? moderateBg,
    Color? critical,
    Color? criticalBg,
  }) {
    return SeverityData(
      normal: normal ?? this.normal,
      normalBg: normalBg ?? this.normalBg,
      mild: mild ?? this.mild,
      mildBg: mildBg ?? this.mildBg,
      moderate: moderate ?? this.moderate,
      moderateBg: moderateBg ?? this.moderateBg,
      critical: critical ?? this.critical,
      criticalBg: criticalBg ?? this.criticalBg,
    );
  }

  @override
  SeverityData lerp(ThemeExtension<SeverityData>? other, double t) {
    if (other is! SeverityData) return this;
    return SeverityData(
      normal: Color.lerp(normal, other.normal, t)!,
      normalBg: Color.lerp(normalBg, other.normalBg, t)!,
      mild: Color.lerp(mild, other.mild, t)!,
      mildBg: Color.lerp(mildBg, other.mildBg, t)!,
      moderate: Color.lerp(moderate, other.moderate, t)!,
      moderateBg: Color.lerp(moderateBg, other.moderateBg, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
      criticalBg: Color.lerp(criticalBg, other.criticalBg, t)!,
    );
  }
}

// ============================================================================
// Motion — semantic by interaction type
// ============================================================================

abstract final class AppMotion {
  // ── Durations by interaction type ─────────────────────────────────────────

  /// Micro-interactions: icon color change, checkbox toggle, ripple.
  static const Duration microInteraction = Duration(milliseconds: 150);

  /// Standard transitions: page fade, card expand, tab switch.
  static const Duration transition = Duration(milliseconds: 250);

  /// Complex transitions: bottom sheet slide, image viewer open.
  static const Duration complexTransition = Duration(milliseconds: 400);

  /// Onboarding animations, first-launch reveals, hero entrances.
  static const Duration reveal = Duration(milliseconds: 600);

  // ── Curves by motion intent ───────────────────────────────────────────────

  /// General-purpose: balanced ease for most animations.
  static const Curve standard = Curves.easeInOut;

  /// Element appearing on screen: decelerates into place.
  static const Curve enter = Curves.easeOut;

  /// Element leaving the screen: accelerates out.
  static const Curve exit = Curves.easeIn;

  /// Dramatic emphasis: hero transitions, feature reveals.
  static const Curve emphasis = Curves.easeInOutCubicEmphasized;
}

// ============================================================================
// Responsive Layout
// ============================================================================
// Tiers drive nav pattern and density; pane minimums drive layout. A template
// branches on whether its panes fit, read via LayoutBuilder constraints only
// — never MediaQuery.of(context).size (design_tokens.md §9.1, §9.6).

abstract final class AppLayout {
  // ── Tiers (§9.2) ──────────────────────────────────────────────────────────
  static const double compactMaxWidth = 599.0;
  static const double mediumMinWidth = 600.0;
  static const double mediumMaxWidth = 1023.0;
  static const double expandedMinWidth = 1024.0;
  static const double expandedMaxWidth = 1599.0;
  static const double ultrawideMinWidth = 1600.0;

  /// Shared breakpoint for two-pane template layouts (e.g. list/grid or tabs/row).
  /// Superseded by the pane minimums below; kept until templates migrate (§9.4).
  static const double templateSplitWidth = 768.0;

  // ── Pane minimums (§9.3) ───────────────────────────────────────────────────
  static const double primaryColumnMin = 480.0;
  static const double panelMinWidth = 320.0;
  static const double twoPaneMinWidth = 900.0;
  static const double threePaneMinWidth = 1120.0;
  static const double formMaxWidth = 400.0;

  /// Alias for NavigationTokens.sideNavWidth, named per §9.3.
  static const double sideNavWidth = NavigationTokens.sideNavWidth;

  /// Alias for NavigationTokens.sideNavCollapsedWidth, named per §9.3.
  static const double sideNavRailWidth = NavigationTokens.sideNavCollapsedWidth;

  // ── Content constraints ──────────────────────────────────────────────────

  /// Max width of the primary content column on wide screens.
  /// Prevents the chat + panel area from stretching across an ultra-wide display.
  static const double contentMaxWidth = 840.0;

  /// Max width for side panels (findings list, study info card) on desktop.
  static const double panelMaxWidth = 360.0;
}

// ============================================================================
// Interactive States
// ============================================================================
// Opacity and geometry tokens for hover, focus, press, and disabled states.
// Web: apply hover/focus overlays via MouseRegion.
// Mobile: InkWell handles press feedback natively; hover tokens are no-ops.

abstract final class AppInteraction {
  // ── Overlay opacities ────────────────────────────────────────────────────

  /// Alpha applied to an element surface when the pointer hovers (web only).
  static const double hoverOverlayOpacity = 0.06;

  /// Alpha applied on pointer press / tap.
  static const double pressedOverlayOpacity = 0.12;

  /// Opacity multiplier for fully disabled elements.
  static const double disabledOpacity = 0.5;

  // ── Focus ring ───────────────────────────────────────────────────────────
  // Color is mode-dependent — read context.colors.borderFocused, not a token here.

  /// Minimum touch target — compact/medium floor; expanded permits 32 but
  /// never requires it, so this is used everywhere (DL §8.5).
  static const double minTouchTarget = 44.0;

  /// Focus ring stroke width.
  static const double focusRingWidth = 2.0;

  /// Gap between the element boundary and the focus ring.
  static const double focusRingOffset = 2.0;

  // ── Mouse cursors (web / desktop) ────────────────────────────────────────
  // Pass these to MouseRegion.cursor; mobile platforms ignore them.

  /// Pointer hand — clickable elements: buttons, links, tappable cards.
  static const MouseCursor mousePointer = SystemMouseCursors.click;

  /// I-beam — text fields and selectable text.
  static const MouseCursor mouseText = SystemMouseCursors.text;

  /// Slash circle — disabled interactive elements.
  static const MouseCursor mouseForbidden = SystemMouseCursors.forbidden;

  /// Grab hand — draggable panels or image viewers.
  static const MouseCursor mouseGrab = SystemMouseCursors.grab;
}

// ============================================================================
// Scrollbar
// ============================================================================
// Web/desktop shows scrollbars persistently; mobile shows them transiently.
// Wired into buildAppTheme() via ScrollbarThemeData.

abstract final class AppScrollbar {
  /// Default scrollbar thumb width.
  static const double thickness = 10.0;

  /// Thumb width while hovered.
  static const double thicknessHovered = 12.0;

  /// Scrollbar track (background channel).
  static const Color trackColor = _Palette.gray100;

  /// Resting scrollbar thumb — subtle, not distracting.
  static const Color thumbColor = _Palette.gray300;

  /// Hovered scrollbar thumb — darker for clear pointer feedback.
  static const Color thumbHoverColor = _Palette.gray500;

  /// Corner radius of the scrollbar thumb pill.
  static const double thumbRadius = AppRadius.button;
}

// ============================================================================
// Tooltip tokens
// ============================================================================
// Medical tools benefit from inline hover-help on every control and field.
// Wired into buildAppTheme() via TooltipThemeData.

abstract final class TooltipTokens {
  /// Dark brand surface — authoritative, matches app header palette.
  static const Color background = _Palette.deepNavy900;

  /// Off-white text on the dark tooltip background.
  static const Color foreground = _Palette.offWhite;

  /// Corner radius — matches the inline element token.
  static const double borderRadius = AppRadius.inlineElement;

  /// Max tooltip width before text wraps to the next line.
  static const double maxWidth = 280.0;

  /// Internal padding.
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );

  /// Vertical offset between the trigger element and the tooltip.
  static const double verticalOffset = AppSpacing.sm;
}

// ============================================================================
// Diagnostic image — outside the theme (design_tokens.md §2.10)
// ============================================================================
// Pixel data is evidence. The perceived contrast of an image depends on its
// surround, so the surround must not vary with a user preference (DL §3.7,
// D-004). These values are mode-exempt and are NOT part of AppColorsData —
// there is deliberately no `context.colors` path to them.

abstract final class DiagnosticImageTokens {
  /// The ground behind and around diagnostic pixel data — the viewer canvas,
  /// and any slot a DICOM image is dropped into.
  ///
  /// Identical in light and dark by design. Specified in design_tokens.md
  /// §10.4 and §2.10; not a new color. Deliberately not the chrome navy —
  /// the boundary between interface and evidence has to stay sharp.
  static const Color canvasGround = _Palette.diagnosticCanvas;

  // The perceptual overlay/heatmap ramp DL §3.7 requires is NOT built yet —
  // design_tokens.md §12 gap 5. Do not approximate it with status or
  // severity colors; that is the violation the gap records.
}

// ============================================================================
// ThemeData builder
// ============================================================================

/// Builds the app's [ThemeData] for the given [brightness] (design_tokens.md
/// §10.5). Defaults to light so existing callers are unaffected; `app.dart`
/// passes both brightnesses explicitly for `MaterialApp.theme`/`darkTheme`.
///
/// Tooltip and scrollbar colors are not yet brightness-aware — no dark value
/// is specified for them anywhere in the design docs (§12 gap 1 follow-up).
ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  final isDark = brightness == Brightness.dark;
  final colors = isDark ? AppColorsData.dark : AppColorsData.light;
  final severity = isDark ? SeverityData.dark : SeverityData.light;

  // `error` needs a genuinely dark-toned counterpart when it estimates
  // light, and a genuinely light-toned one when it estimates dark.
  // `textOnBrand` is light-toned in both modes (safe for the "needs light
  // text" branch), but `textPrimary` is only dark-toned in light mode — in
  // dark mode the whole text ramp is light-on-dark, so it cannot supply the
  // "needs dark text" branch there. `surfacePage` is dark in dark mode and
  // is never reached in light mode (`textPrimary` already covers that case
  // correctly, since light mode's own error color estimates dark), so this
  // preserves light mode's existing behavior unchanged and fixes dark mode
  // (statusError `#FF9A93` estimates light: onError was `#E4E8ED`, 1.66:1;
  // now `#0E141B`, 9.07:1).
  final onErrorDark = isDark ? colors.surfacePage : colors.textPrimary;
  final onError = ThemeData.estimateBrightnessForColor(colors.statusError) ==
          Brightness.dark
      ? colors.textOnBrand
      : onErrorDark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: colors.surfacePage,
    extensions: <ThemeExtension<dynamic>>[colors, severity],
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: AppColors.brandPrimary,
      onPrimary: colors.textOnBrand,
      primaryContainer: colors.surfaceBrandSubdued,
      onPrimaryContainer: colors.textOnBrandSubdued,
      secondary: AppColors.brandAccent,
      onSecondary: colors.interactivePrimaryForeground,
      secondaryContainer: colors.surfaceAccent,
      onSecondaryContainer: colors.textOnAccent,
      tertiary: AppColors.brandSecondary,
      onTertiary: colors.textOnBrand,
      error: colors.statusError,
      onError: onError,
      errorContainer: colors.statusErrorSubdued,
      onErrorContainer: colors.statusError,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.surfaceSubdued,
      outline: colors.border,
      outlineVariant: colors.borderSubdued,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surfaceBrand,
      foregroundColor: colors.textOnBrand,
      elevation: NavigationTokens.appBarElevation,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderCard),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(
        borderRadius: AppRadius.borderInput,
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderInput,
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderInput,
        borderSide: BorderSide(color: colors.borderFocused, width: 2),
      ),
      hintStyle: AppTypography.bodyMd.copyWith(color: colors.textPlaceholder),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.interactivePrimary,
        foregroundColor: colors.interactivePrimaryForeground,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderButton),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        textStyle: AppTypography.labelLg,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.interactivePrimary,
      selectionColor: colors.surfaceAccent,
      selectionHandleColor: colors.interactivePrimary,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: TooltipTokens.background,
        borderRadius: BorderRadius.circular(TooltipTokens.borderRadius),
        boxShadow: AppElevation.overlay,
      ),
      textStyle: AppTypography.bodySm.copyWith(color: TooltipTokens.foreground),
      padding: TooltipTokens.padding,
      verticalOffset: TooltipTokens.verticalOffset,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? AppScrollbar.thicknessHovered
            : AppScrollbar.thickness,
      ),
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? AppScrollbar.thumbHoverColor
            : AppScrollbar.thumbColor,
      ),
      trackColor: WidgetStateProperty.all(AppScrollbar.trackColor),
      radius: const Radius.circular(AppScrollbar.thumbRadius),
    ),
  );
}
