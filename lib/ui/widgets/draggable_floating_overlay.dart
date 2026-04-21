import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/simple_logger_overlay.dart';

import '../../core/log_storage_service.dart';

class SimpleOverlayDraggableDebuggerFAB extends StatefulWidget {
  const SimpleOverlayDraggableDebuggerFAB({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<SimpleOverlayDraggableDebuggerFAB> createState() =>
      _SimpleOverlayDraggableDebuggerFABState();
}

class _SimpleOverlayDraggableDebuggerFABState
    extends State<SimpleOverlayDraggableDebuggerFAB>
    with TickerProviderStateMixin {
  Offset _offset = const Offset(20, 100);
  bool _pressed = false;
  bool _isDragging = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _snapController;
  Animation<double>? _snapXAnimation;
  Animation<double>? _snapYAnimation;

  Offset _snapStart = Offset.zero;
  Offset _snapEnd = Offset.zero;

  StreamSubscription? _simpleSubscription;
  StreamSubscription? _networkSubscription;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _simpleSubscription = SimpleOverlayLogStorageService().simpleLogStream.listen((_) {
      if (mounted) _pulse();
    });
    _networkSubscription =
        SimpleOverlayLogStorageService().networkLogStream.listen((_) {
      if (mounted) _pulse();
    });
  }

  void _pulse() {
    _pulseController.forward(from: 0);
  }

  void _snapToEdge() {
    final size = MediaQuery.of(context).size;
    final targetX = _offset.dx < size.width / 2 ? 16.0 : size.width - 70.0;
    final targetY = _offset.dy.clamp(60.0, size.height - 120.0);

    _snapStart = _offset;
    _snapEnd = Offset(targetX, targetY);

    _snapXAnimation = Tween<double>(begin: _snapStart.dx, end: _snapEnd.dx)
        .animate(CurvedAnimation(parent: _snapController, curve: Curves.elasticOut));
    _snapYAnimation = Tween<double>(begin: _snapStart.dy, end: _snapEnd.dy)
        .animate(CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic));

    _snapController.removeListener(_onSnapTick);
    _snapController.addListener(_onSnapTick);
    _snapController.forward(from: 0).then((_) {
      _snapController.removeListener(_onSnapTick);
    });
  }

  void _onSnapTick() {
    if (mounted && _snapXAnimation != null && _snapYAnimation != null) {
      setState(() {
        _offset = Offset(_snapXAnimation!.value, _snapYAnimation!.value);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _snapController.dispose();
    _simpleSubscription?.cancel();
    _networkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final overlayTheme =
        SimpleLoggerOverlayConfig.instance.buildTheme(brightness);
    final cs = overlayTheme.colorScheme;

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Theme(
        data: overlayTheme,
        child: GestureDetector(
          onPanStart: (_) => setState(() => _isDragging = true),
          onPanUpdate: (details) {
            setState(() => _offset += details.delta);
          },
          onPanEnd: (_) {
            setState(() => _isDragging = false);
            _snapToEdge();
          },
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () {
            SimpleLoggerOverlay.show(context, navigatorKey: widget.navigatorKey);
          },
          child: AnimatedScale(
            scale: _pressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, child) {
                  // Shadow swells with the pulse scale — creates depth pop
                  final pulseBoost =
                      (_pulseAnimation.value - 1.0).abs() * 14.0;
                  return Material(
                    elevation: (_isDragging ? 12.0 : 6.0) + pulseBoost,
                    shadowColor: cs.primary.withValues(
                        alpha: 0.4 + (pulseBoost * 0.025).clamp(0.0, 0.3)),
                    shape: const CircleBorder(),
                    color: cs.primaryContainer,
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Icon(
                    Icons.bug_report_outlined,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
