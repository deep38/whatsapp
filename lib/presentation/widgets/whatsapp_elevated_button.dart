import 'package:flutter/material.dart';

class WhatsAppElevatedButton extends StatelessWidget {
  final bool _disabled;

  final Widget child;
  final Function()? onPressed;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double? width;

  const WhatsAppElevatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    this.borderRadius = 5,
    this.width,
  }) : _disabled = onPressed == null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _disabled ? Colors.grey : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        
        child: InkWell(
          
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            width: width,
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).canvasColor,
              ),
              child: Padding(padding: padding, child: child)
            ),
          ),
        ),
      ),
    );
  }
}
