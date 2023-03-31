import 'package:flutter/material.dart';

class AnimatedCrossScale extends StatefulWidget {
  final Widget firstChild;
  final Widget secondChild;
  final Duration duration;
  final CrossFadeState crossFadeState;

  const AnimatedCrossScale({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.duration,
    required this.crossFadeState,
  });

  @override
  State<AnimatedCrossScale> createState() => _AnimatedCrossScaleState();
}

class _AnimatedCrossScaleState extends State<AnimatedCrossScale>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedScale(
          scale: widget.crossFadeState == CrossFadeState.showFirst ? 1 : 0,
          duration: widget.duration,
          child: widget.firstChild,
        ),
        AnimatedScale(
          duration: widget.duration,
          scale: widget.crossFadeState == CrossFadeState.showSecond ? 1 : 0,
          child: widget.secondChild,
        ),
      ],
    );
  }
}
