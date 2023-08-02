
import 'package:flutter/material.dart';

class UnreadCountIndicator extends StatelessWidget {
  const UnreadCountIndicator({
    super.key,
    this.size = 20,
    required this.text,
  });

  final double size;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).canvasColor,
        overflow: TextOverflow.clip,
        fontSize: ((-5/2) * text.length) + (29 / 2),
      )),
    );
  }
}