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
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.interactivePrimary,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _placeholder(
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.icon,
          ),
        );
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _placeholder({required Widget child}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceSubdued,
      alignment: Alignment.center,
      child: child,
    );
  }
}
