import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A controller that triggers a shake animation
/// Call [shake] to trigger the shake
class ShakeController extends ChangeNotifier {
  void shake() => notifyListeners();
}

/// A widget that shakes its child when the controller triggers
/// - [duration] is the duration of the shake
/// - [deltaX] is the maximum distance to shake
/// - [oscillations] is the number of oscillations of the shake
/// - [curve] is the curve of the shake
/// - [controller] is the controller that triggers the shake
class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    super.key,
    required this.controller,
    this.duration = const Duration(milliseconds: 500),
    this.deltaX = 4,
    this.oscillations = 6,
    this.curve = Curves.linear,
  });

  final Duration duration;
  final double deltaX;
  final int oscillations;
  final Curve curve;
  final ShakeController controller;

  @override
  _ShakeWidgetState createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );

    widget.controller.addListener(_startShaking);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_startShaking);
    _animationController.dispose();
    super.dispose();
  }

  void _startShaking() {
    _animationController.forward(from: 0);
  }

  /// Create a sinusoidal curve that starts and ends at 0
  /// Oscillates with increasing amplitude to the middle and then decreasing
  /// amplitude to the end.
  double _wave(double t) =>
      sin(widget.oscillations * 2 * pi * t) * (1 - (2 * t - 1).abs());

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
            offset: Offset(
              widget.deltaX * _wave(_animation.value),
              0,
            ),
            child: AnimatedContainer(
              duration: widget.duration,
              padding: EdgeInsets.all(3.w),
              child: Icon(
                Icons.check,
                color: _animation.value < 0.05 || _animation.value > 0.95
                    ? Colors.black
                    : const Color.fromARGB(255, 198, 15, 58),
              ),
            ),
          ));
}
