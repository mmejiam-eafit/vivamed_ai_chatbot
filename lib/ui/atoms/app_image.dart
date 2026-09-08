import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

// Uses Image.network. Swap for CachedNetworkImage once cached_network_image
// is declared in pubspec.yaml.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _placeholder(
          context,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: context.colors.interactivePrimary,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _placeholder(
          context,
          child: Icon(
            Icons.broken_image_outlined,
            color: context.colors.icon,
          ),
        );
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _placeholder(BuildContext context, {required Widget child}) {
    return Container(
      width: width,
      height: height,
      color: context.colors.surfaceSubdued,
      alignment: Alignment.center,
      child: child,
    );
  }
}
