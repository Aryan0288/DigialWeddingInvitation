import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum ScrollEntranceType { fadeIn, slideUp, scaleIn, slideAndScale }

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
    this.duration = AppDesign.durationMedium,
  });

  @override
  State<ScrollEntrance> createState() => _ScrollEntranceState();
}

class _ScrollEntranceState extends State<ScrollEntrance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  late Animation<double> _scale;

  ScrollableState? _scrollableState;
  bool _isAnimationTriggered = false;
  Timer? _delayTimer;

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
          ? const Offset(0.0, 0.12) 
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _removeScrollListener();
    _scrollableState = Scrollable.maybeOf(context);
    if (_scrollableState != null) {
      _scrollableState!.position.addListener(_checkVisibility);
      // Trigger a check immediately after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkVisibility();
      });
    } else {
      // If there's no scrollable ancestor, trigger immediately
      _triggerAnimation();
    }
  }

  void _removeScrollListener() {
    if (_scrollableState != null) {
      try {
        _scrollableState!.position.removeListener(_checkVisibility);
      } catch (_) {
        // Scroll position might be disposed
      }
      _scrollableState = null;
    }
  }

  int _lastCheckTime = 0;
  bool _hasDeferredCheck = false;

  void _checkVisibility() {
    if (_isAnimationTriggered) return;
    if (!mounted) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastCheckTime < 50) {
      _scheduleDeferredCheck();
      return;
    }
    _lastCheckTime = now;
    _performCheck();
  }

  void _scheduleDeferredCheck() {
    if (_hasDeferredCheck) return;
    _hasDeferredCheck = true;
    Future.delayed(const Duration(milliseconds: 50), () {
      _hasDeferredCheck = false;
      if (mounted && !_isAnimationTriggered) {
        _performCheck();
      }
    });
  }

  void _performCheck() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;
    if (!renderObject.hasSize) return;

    try {
      final position = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      final double screenHeight = MediaQuery.of(context).size.height;

      // Trigger animation when the widget enters the viewport (partially visible)
      if (position.dy < screenHeight - 20 && position.dy + size.height > 20) {
        _triggerAnimation();
      }
    } catch (_) {
      // Catch layout changes during fast scroll teardowns
    }
  }

  void _triggerAnimation() {
    if (_isAnimationTriggered) return;
    _isAnimationTriggered = true;
    _removeScrollListener();

    _delayTimer = Timer(
      Duration(milliseconds: widget.delayIndex * 60),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _removeScrollListener();
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: ScaleTransition(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}
