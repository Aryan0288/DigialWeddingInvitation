import 'dart:async';
import 'package:flutter/material.dart';

enum ScrollEntranceType { fadeIn, slideUp, scaleIn, slideAndScale }

/// One-shot premium entrance animation.
///
/// Style (per design spec):
///   - Fade:      opacity 0 -> 1
///   - Slide up:  translateY 40 -> 0
///   - Scale in:  scale 0.96 -> 1.00
///   - Duration:  500ms, Curves.easeOutCubic
///   - Stagger:   delayIndex * 70ms
///
/// Performance: a single [AnimationController] drives all transforms. Once the
/// animation completes the controller is disposed and [child] is rendered
/// directly (zero ticker cost). There is no keep-alive, so off-screen cells in
/// a lazy list are freed normally.
class ScrollEntrance extends StatefulWidget {
  final Widget child;
  final ScrollEntranceType type;
  final int delayIndex;
  final Duration duration;

  const ScrollEntrance({
    super.key,
    required this.child,
    this.type = ScrollEntranceType.fadeIn,
    this.delayIndex = 0,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<ScrollEntrance> createState() => _ScrollEntranceState();
}

class _ScrollEntranceState extends State<ScrollEntrance>
    with SingleTickerProviderStateMixin {
  static const double _slideDistance = 40.0;

  AnimationController? _controller;
  late Animation<double> _anim;
  Timer? _delayTimer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    final c = AnimationController(vsync: this, duration: widget.duration);
    _controller = c;
    _anim = CurvedAnimation(parent: c, curve: Curves.easeOutCubic);
    _scheduleAnimation();
  }

  void _scheduleAnimation() {
    _delayTimer = Timer(
      Duration(milliseconds: widget.delayIndex * 70),
      () {
        if (!mounted) return;
        _controller?.forward().whenComplete(_onAnimationDone);
      },
    );
  }

  void _onAnimationDone() {
    if (!mounted) return;
    _controller?.dispose();
    _controller = null;
    setState(() => _completed = true);
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Once the animation is done, render the child with no overhead.
    if (_completed) return widget.child;

    final bool doSlide = widget.type == ScrollEntranceType.slideUp ||
        widget.type == ScrollEntranceType.slideAndScale;
    final bool doScale = widget.type == ScrollEntranceType.scaleIn ||
        widget.type == ScrollEntranceType.slideAndScale;

    return AnimatedBuilder(
      animation: _anim,
      child: widget.child,
      builder: (context, child) {
        final double t = _anim.value;
        Widget result = child!;

        if (doScale) {
          result = Transform.scale(scale: 0.96 + (0.04 * t), child: result);
        }
        if (doSlide) {
          result = Transform.translate(
            offset: Offset(0, _slideDistance * (1 - t)),
            child: result,
          );
        }
        return Opacity(opacity: t, child: result);
      },
    );
  }
}
