import 'package:flutter/material.dart';
import '../../../utils/mapers/asset_images.dart';

class ProfilePhoto extends StatelessWidget {
  final ImageProvider<Object> placeholder;
  final ImageProvider<Object> image;
  final Widget? indicator;
  final double size;

  const ProfilePhoto({
    super.key,
    required this.placeholder,
    required this.image,
    this.indicator,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    
    return SizedBox.fromSize(
      size: Size(size, size),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: ClipOval(
                child: FadeInImage(
                  fadeInDuration: const Duration(milliseconds: 100),
                  fadeOutDuration: const Duration(milliseconds: 100),
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: placeholder,
                  image: image,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(AssetImages.default_profile);
                  },
                  fit: BoxFit.cover,
                ),
              ),
            ),
    
            if(indicator != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: indicator!
              )
        ],
      ),
    );
  }
}