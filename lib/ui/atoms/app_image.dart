import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

// A plain http(s) URL uses Image.network (swap for CachedNetworkImage once
// cached_network_image is declared in pubspec.yaml); anything else is treated
// as a bundled asset path (declared in pubspec.yaml's flutter/assets) and
// uses Image.asset -- lets mock data mix real bundled images with network
// placeholders under the same String url, no call site needs to know which.
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

  bool get _isNetwork => url.startsWith('http://') || url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final image = _isNetwork
        ? Image.network(
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
            errorBuilder: _errorBuilder,
          )
        : Image.asset(
            url,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: _errorBuilder,
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return _placeholder(
      context,
      child: Icon(
        Icons.broken_image_outlined,
        color: context.colors.icon,
      ),
    );
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
