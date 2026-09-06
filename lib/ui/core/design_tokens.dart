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
  // ignore: unused_field
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

  // Status
  static const Color green700 = Color(0xFF2E7D4F);
  static const Color green50 = Color(0xFFD9F0E3);
  static const Color amber700 = Color(0xFFD4910A);
  static const Color amber50 = Color(0xFFFFF4D6);
  static const Color red700 = Color(0xFFC62828);
  static const Color red50 = Color(0xFFFFE0E0);
  static const Color blue700 = Color(0xFF0277BD);
  static const Color blue50 = Color(0xFFDCEEF9);
}

// ============================================================================
// Semantic Colors
// ============================================================================
// Every token answers: "What is this color FOR?" — not "What color IS it?"

abstract final class AppColors {
  // ── Surfaces ────────────────────────────────────────────────────────────
  // Backgrounds and fill areas.

  /// Main scaffold / page background.
  static const Color surfacePage = _Palette.offWhite;

  /// Default card, dialog, and input fill.
  static const Color surface = _Palette.white;

  /// Subtle alternate surface: striped rows, hover fills, empty states.
  static const Color surfaceSubdued = _Palette.gray100;

  /// Primary brand dark surface: hero sections, headers.
  static const Color surfaceBrand = _Palette.deepNavy;

  /// Secondary brand dark surface: drawer panels, section accents.
  static const Color surfaceBrandSecondary = _Palette.mediumNavy;

  /// Accent-tinted light surface: selected items, highlighted rows, chips.
  static const Color surfaceAccent = _Palette.tealBlue50;

  /// Primary brand tinted light surface: selected primary items, info banners.
  static const Color surfaceBrandSubdued = _Palette.deepNavy50;

  /// Secondary brand tinted light surface: secondary selections.
  static const Color surfaceBrandSecondarySubdued = _Palette.mediumNavy50;

  // ── Text ────────────────────────────────────────────────────────────────
  // Foreground colors for readable text.

  /// Primary body text on light surfaces.
  static const Color textPrimary = _Palette.gray900;

  /// Secondary text: subtitles, descriptions, less-prominent copy.
  static const Color textSecondary = _Palette.gray700;

  /// Tertiary text: helper text, supplementary labels.
  static const Color textTertiary = _Palette.gray600;

  /// Placeholder text inside input fields.
  static const Color textPlaceholder = _Palette.gray400;

  /// Disabled text: inactive labels, unavailable options.
  static const Color textDisabled = _Palette.gray400;

  /// Timestamps, fine print, low-priority metadata.
  static const Color textMuted = _Palette.gray500;

  /// Text on brand-dark surfaces (surfaceBrand, surfaceBrandSecondary).
  static const Color textOnBrand = _Palette.offWhite;

  /// Text inside accent-tinted surfaces (surfaceAccent).
  static const Color textOnAccent = _Palette.tealBlue800;

  /// Text inside primary brand-tinted surfaces (surfaceBrandSubdued).
  static const Color textOnBrandSubdued = _Palette.deepNavy900;

  /// Text inside secondary brand-tinted surfaces.
  static const Color textOnBrandSecondarySubdued = _Palette.mediumNavy800;

  /// Link text and inline interactive text.
  static const Color textLink = _Palette.tealBlue600;

  /// Link text on pointer hover (web).
  static const Color textLinkHover = _Palette.tealBlue400;

  /// Already-visited link text.
  static const Color textLinkVisited = _Palette.tealBlue800;

  // ── Icons ───────────────────────────────────────────────────────────────

  /// Default icon tint on light surfaces.
  static const Color icon = _Palette.gray600;

  /// Icon tint on brand-dark surfaces.
  static const Color iconOnBrand = _Palette.offWhite;

  /// Accent icon tint: active states, selected tabs.
  static const Color iconAccent = _Palette.tealBlue;

  /// Disabled icon tint.
  static const Color iconDisabled = _Palette.gray400;

  // ── Borders ─────────────────────────────────────────────────────────────

  /// Default border: cards, containers, sections.
  static const Color border = _Palette.gray300;

  /// Subtle border: light separators, inner dividers.
  static const Color borderSubdued = _Palette.gray200;

  /// Focused input border.
  static const Color borderFocused = _Palette.tealBlue400;

  /// Strong border: selected items, active outlines.
  static const Color borderSelected = _Palette.tealBlue;

  // ── Interactive ─────────────────────────────────────────────────────────
  // Colors for actionable elements: buttons, toggles, links.

  /// Primary action fill: main CTA buttons.
  static const Color interactivePrimary = _Palette.tealBlue;

  /// Text/icon on primary action fill.
  static const Color interactivePrimaryForeground = _Palette.offWhite;

  /// Secondary action fill: outlined / subdued buttons.
  static const Color interactiveSecondary = _Palette.white;

  /// Text/icon on secondary action fill.
  static const Color interactiveSecondaryForeground = _Palette.tealBlue;

  /// Hover/pressed tint for interactive elements.
  static const Color interactiveHover = _Palette.tealBlue600;

  /// Mid-tone interactive accent: progress bars, sliders, active indicators.
  static const Color interactiveAccent = _Palette.tealBlue400;

  /// Disabled interactive element fill.
  static const Color interactiveDisabled = _Palette.gray200;

  /// Text on disabled interactive elements.
  static const Color interactiveDisabledForeground = _Palette.gray500;

  // ── Status ──────────────────────────────────────────────────────────────
  // App-level operational status. NOT for clinical severity (use SeverityTokens).

  /// Success: uploads complete, operations confirmed.
  static const Color statusSuccess = _Palette.green700;
  static const Color statusSuccessSubdued = _Palette.green50;

  /// Warning: low confidence, connectivity issues, stale data.
  static const Color statusWarning = _Palette.amber700;
  static const Color statusWarningSubdued = _Palette.amber50;

  /// Error: failed operations, invalid input, server errors.
  static const Color statusError = _Palette.red700;
  static const Color statusErrorSubdued = _Palette.red50;

  /// Info: tips, non-actionable notices, informational banners.
  static const Color statusInfo = _Palette.tealBlue400;
  static const Color statusInfoSubdued = _Palette.tealBlue50;

  // ── Brand reference ─────────────────────────────────────────────────────
  // Exposed for rare cases where the raw brand color is needed semantically
  // (e.g., logo rendering, brand-specific illustrations).

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
  /// No pathology detected, healthy findings.
  static const Color normal = _Palette.green700;
  static const Color normalBg = _Palette.green50;

  /// Minor observations, low clinical significance.
  static const Color mild = _Palette.blue700;
  static const Color mildBg = _Palette.blue50;

  /// Findings requiring attention or follow-up.
  static const Color moderate = _Palette.amber700;
  static const Color moderateBg = _Palette.amber50;

  /// Urgent findings, immediate action needed.
  static const Color critical = _Palette.red700;
  static const Color criticalBg = _Palette.red50;
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
// Breakpoints follow Material Design 3 adaptive layout guidance.
// Use with LayoutBuilder or MediaQuery to select layout tiers.

abstract final class AppLayout {
  // ── Breakpoints ─────────────────────────────────────────────────────────
  static const double mobileMaxWidth = 599.0;
  static const double tabletMinWidth = 600.0;
  static const double tabletMaxWidth = 959.0;
  static const double desktopMinWidth = 960.0;
  static const double wideMinWidth = 1440.0;

  /// Shared breakpoint for two-pane template layouts (e.g. list/grid or tabs/row).
  static const double templateSplitWidth = 768.0;

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

  /// Focus ring outline color (keyboard navigation, accessibility).
  static const Color focusRingColor = AppColors.borderFocused;

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
// ThemeData builder
// ============================================================================

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.surfacePage,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.brandPrimary,
      onPrimary: AppColors.textOnBrand,
      primaryContainer: AppColors.surfaceBrandSubdued,
      onPrimaryContainer: AppColors.textOnBrandSubdued,
      secondary: AppColors.brandAccent,
      onSecondary: AppColors.interactivePrimaryForeground,
      secondaryContainer: AppColors.surfaceAccent,
      onSecondaryContainer: AppColors.textOnAccent,
      tertiary: AppColors.brandSecondary,
      onTertiary: AppColors.textOnBrand,
      error: AppColors.statusError,
      onError: _Palette.white,
      errorContainer: AppColors.statusErrorSubdued,
      onErrorContainer: AppColors.statusError,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceSubdued,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubdued,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: NavigationTokens.appBarBackground,
      foregroundColor: NavigationTokens.appBarForeground,
      elevation: NavigationTokens.appBarElevation,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderCard),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ChatTokens.inputBackground,
      border: OutlineInputBorder(
        borderRadius: AppRadius.borderInput,
        borderSide: const BorderSide(color: ChatTokens.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderInput,
        borderSide: const BorderSide(color: ChatTokens.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderInput,
        borderSide:
            const BorderSide(color: ChatTokens.inputBorderFocused, width: 2),
      ),
      hintStyle:
          AppTypography.bodyMd.copyWith(color: ChatTokens.inputPlaceholder),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.interactivePrimary,
        foregroundColor: AppColors.interactivePrimaryForeground,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderButton),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        textStyle: AppTypography.labelLg,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: ChatTokens.inputCursorColor,
      selectionColor: ChatTokens.inputSelectionColor,
      selectionHandleColor: AppColors.interactivePrimary,
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
