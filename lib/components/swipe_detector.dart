import 'package:flutter/material.dart';

class SwipeDetector extends StatefulWidget {
  const SwipeDetector({
    super.key,
    this.onSwipeLeft,
    this.onSwipeRight,
    required this.child,
  });

  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final Widget child;

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector> {
  static const double _triggerOffset = 24;
  static const double _triggerVelocity = 280;
  double _initialDrag = 0;
  double _distanceDrag = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (DragStartDetails details) {
        _initialDrag = details.globalPosition.dx;
        _distanceDrag = 0;
      },
      onPanUpdate: (DragUpdateDetails details) {
        _distanceDrag = details.globalPosition.dx - _initialDrag;
      },
      onPanEnd: (DragEndDetails details) {
        final velocity = details.velocity.pixelsPerSecond.dx;
        if (_distanceDrag <= -_triggerOffset || velocity <= -_triggerVelocity) {
          widget.onSwipeLeft?.call();
        } else if (_distanceDrag >= _triggerOffset || velocity >= _triggerVelocity) {
          widget.onSwipeRight?.call();
        }
        _initialDrag = 0;
        _distanceDrag = 0;
      },
      child: widget.child,
    );
  }
}