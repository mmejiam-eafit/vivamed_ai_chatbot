import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Which part of the RadAsk mark to render. See assets/brand/README.md for
/// the color derivation.
enum AppLogoVariant { mark, full }

/// The RadAsk brand mark: a speech-bubble icon, optionally paired with the
/// "RadAsk" wordmark. Loads the same static SVGs `assets/brand/README.md`
/// documents — colors are baked into those files as `AppColors.brand*`
/// (design_tokens.md §2.7, mode-invariant), so this widget never reads
/// `context.colors` and renders identically in light and dark mode.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.variant = AppLogoVariant.full,
    this.size = 32.0,
    this.semanticLabel = 'RadAsk',
  });

  final AppLogoVariant variant;

  /// The rendered SVG's height; width follows its own aspect ratio.
  final double size;

  final String? semanticLabel;

  static const _assetFor = {
    AppLogoVariant.mark: 'assets/brand/logo-mark.svg',
    AppLogoVariant.full: 'assets/brand/logo-full.svg',
  };

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetFor[variant]!,
      height: size,
      semanticsLabel: semanticLabel,
    );
  }
}
