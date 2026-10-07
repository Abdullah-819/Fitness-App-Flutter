import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/developer.dart';

/// Full-screen photo viewer: the avatar flies into place (Hero), double-tap
/// zooms in/out, pinch zooms freely, dragging down dismisses, and a tap or
/// the close button closes it.
class DeveloperPhotoViewer extends StatefulWidget {
  final Developer developer;

  const DeveloperPhotoViewer({super.key, required this.developer});

  static Future<void> show(BuildContext context, Developer developer) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, _) => FadeTransition(
          opacity: animation,
          child: DeveloperPhotoViewer(developer: developer),
        ),
      ),
    );
  }

  @override
  State<DeveloperPhotoViewer> createState() => _DeveloperPhotoViewerState();
}

class _DeveloperPhotoViewerState extends State<DeveloperPhotoViewer>
    with SingleTickerProviderStateMixin {
  static const _zoomScale = 2.6;

  final TransformationController _transform = TransformationController();
  late final AnimationController _zoomAnim;
  Animation<Matrix4>? _zoomTween;
  Offset _doubleTapAt = Offset.zero;

  double _dragY = 0;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _zoomAnim =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 260),
        )..addListener(() {
          final tween = _zoomTween;
          if (tween != null) _transform.value = tween.value;
        });
  }

  @override
  void dispose() {
    _zoomAnim.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final end = _zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -_doubleTapAt.dx * (_zoomScale - 1),
              -_doubleTapAt.dy * (_zoomScale - 1),
              0,
              1,
            )
            ..scaleByDouble(_zoomScale, _zoomScale, 1, 1));
    _zoomTween = Matrix4Tween(
      begin: _transform.value,
      end: end,
    ).animate(CurvedAnimation(parent: _zoomAnim, curve: Curves.easeOutCubic));
    _zoomAnim.forward(from: 0);
    _zoomed = !_zoomed;
  }

  @override
  Widget build(BuildContext context) {
    final dev = widget.developer;
    // Image fades and shrinks a little as it is dragged down.
    final dragFraction = (_dragY / 300).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
            onDoubleTap: _toggleZoom,
            onVerticalDragUpdate: _zoomed
                ? null
                : (d) => setState(
                    () => _dragY = (_dragY + d.delta.dy).clamp(0, 600),
                  ),
            onVerticalDragEnd: _zoomed
                ? null
                : (d) {
                    if (_dragY > 120 || (d.primaryVelocity ?? 0) > 700) {
                      Navigator.of(context).maybePop();
                    } else {
                      setState(() => _dragY = 0);
                    }
                  },
            child: SafeArea(
              child: AnimatedContainer(
                duration: _dragY == 0
                    ? const Duration(milliseconds: 220)
                    : Duration.zero,
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, _dragY, 0),
                child: Opacity(
                  opacity: 1 - dragFraction * 0.5,
                  child: Center(
                    child: Hero(
                      tag: dev.heroTag,
                      child: InteractiveViewer(
                        transformationController: _transform,
                        minScale: 1,
                        maxScale: 4,
                        onInteractionEnd: (_) => _zoomed =
                            _transform.value.getMaxScaleOnAxis() > 1.05,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            dev.imageAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  LucideIcons.user,
                                  size: 96,
                                  color: Colors.white54,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(LucideIcons.x, color: Colors.white),
                  tooltip: 'Close',
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Opacity(
                  opacity: 1 - dragFraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dev.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Double-tap or pinch to zoom · drag down to close',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
