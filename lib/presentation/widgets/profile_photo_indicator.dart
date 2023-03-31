import 'package:flutter/material.dart';

class ProfilePhotoIndicator extends StatelessWidget {
  final Icon? icon;
  final Color? backgroundColor;
  final double? iconSize;
  final Size? size;
  final double borderWidth;

  const ProfilePhotoIndicator({
    super.key,
    this.icon,
    this.backgroundColor,
    this.iconSize,
    this.size,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size?.width ?? 22,
        height: size?.height ?? 22,
        
        alignment: Alignment.center,
        
      
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).canvasColor,
            width: borderWidth,
          ),
        ),
      
        child: icon,
      );
  }
}