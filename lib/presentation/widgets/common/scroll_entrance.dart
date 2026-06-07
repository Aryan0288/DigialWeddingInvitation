import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum ScrollEntranceType { fadeIn, slideUp, scaleIn, slideAndScale }

class ScrollEntrance extends StatefulWidget {
  final Widget child;
  final ScrollEntranceType type;
  final int delayIndex;
  final Duration duration;
  final bool triggerOnScroll;

  const ScrollEntrance({
    super.key,
    required this.child,
    this.type = ScrollEntranceType.fadeIn,
    this.delayIndex = 0,
    this.duration = AppDesign.durationMedium,
    this.triggerOnScroll = true,
  });

  @override
  State<ScrollEntrance> createState() => _ScrollEntranceState();
}

class _ScrollEntranceState extends State<ScrollEntrance> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  late Animation<double> _scale;
  Timer? _delayTimer;
  bool _isAnimationTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _offset = Tween<Offset>(
      begin: (widget.type == ScrollEntranceType.slideUp || widget.type == ScrollEntranceType.slideAndScale) 
          ? const Offset(0.0, 0.05) 
          : Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );

    _scale = Tween<double>(
      begin: (widget.type == ScrollEntranceType.scaleIn || widget.type == ScrollEntranceType.slideAndScale) 
          ? 0.95 
          : 1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _triggerAnimation();
  }

  @override
  bool get wantKeepAlive => _isAnimationTriggered;

  void _triggerAnimation() {
    if (_isAnimationTriggered) return;
    _isAnimationTriggered = true;
    updateKeepAlive();

    _delayTimer = Timer(
      Duration(milliseconds: widget.delayIndex * 30),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    Widget result = widget.child;
    
    if (widget.type == ScrollEntranceType.scaleIn || widget.type == ScrollEntranceType.slideAndScale) {
      result = ScaleTransition(
        scale: _scale,
        child: result,
      );
    }
    
    if (widget.type == ScrollEntranceType.slideUp || widget.type == ScrollEntranceType.slideAndScale) {
      result = SlideTransition(
        position: _offset,
        child: result,
      );
    }
    
    return FadeTransition(
      opacity: _opacity,
      child: result,
    );
  }
}
