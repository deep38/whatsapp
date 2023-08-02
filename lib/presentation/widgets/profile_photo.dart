import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../utils/mapers/asset_images.dart';

class ProfilePhoto extends StatelessWidget {
  final String placeholderPath;
  final String imageUrl;
  final ImageProvider<Object>? imageProvider;
  final String? url;
  final Widget? indicator;
  final double size;
  final VoidCallback? onTap;
  final bool showLoading;

  const ProfilePhoto({
    super.key,
    required this.placeholderPath,
    required this.imageUrl,
    this.imageProvider,
    this.indicator,
    this.size = 32,
    this.onTap,
    this.url,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(size, size),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              radius: 100,
              borderRadius: BorderRadius.circular(size),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  imageBuilder: (context, networkImageProvider) {
                    return FadeInImage(
                  fadeInDuration: const Duration(milliseconds: 100),
                  fadeOutDuration: const Duration(milliseconds: 100),
                  // width: double.infinity,
                  // height: double.infinity,
                  placeholder: AssetImage(placeholderPath),
                  image:  imageProvider ?? networkImageProvider,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(placeholderPath);
                  },
                  fit: BoxFit.cover,
                );
                
                  },
                  placeholder: (context, url) {
                    return Image.asset(placeholderPath);
                  },
                  errorWidget: (context, url, error) {
                    return Image.asset(placeholderPath);
                  },
                ),

                // Ink.image(
                //   image: image,
                //   child: InkWell(
                //     onTap: onTap,
                //   ),
                //     FadeInImage(
                //   fadeInDuration: const Duration(milliseconds: 100),
                //   fadeOutDuration: const Duration(milliseconds: 100),
                //   // width: double.infinity,
                //   // height: double.infinity,
                //   placeholder: placeholder,
                //   image: image,
                //   imageErrorBuilder: (context, error, stackTrace) {
                //     return Image.asset(placeholderPath);
                //   },
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
          ),
          // ),
          if (showLoading)
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator.adaptive(),
              ),
            ),
          if (indicator != null)
            Positioned(bottom: 0, right: 0, child: indicator!)
        ],
      ),
    );
  }
}
