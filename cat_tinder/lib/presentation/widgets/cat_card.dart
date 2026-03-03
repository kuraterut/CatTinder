import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/cat_image.dart';

class CatCard extends StatefulWidget {
  final CatImage catImage;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onTap;

  const CatCard({
    super.key,
    required this.catImage,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTap,
  });

  @override
  State<CatCard> createState() => _CatCardState();
}

class _CatCardState extends State<CatCard> with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isDragging = false;
  late AnimationController _resetController;

  static const double _swipeThreshold =
      80.0;
  static const double _swipeVelocityThreshold =
      500.0;
  static const double _maxDragOffset = 400.0;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onSwipeComplete(bool isRightSwipe) {
    if (isRightSwipe) {
      widget.onSwipeRight();
    } else {
      widget.onSwipeLeft();
    }
  }

  void _resetPosition() {
    _resetController.animateTo(0, duration: const Duration(milliseconds: 300));
    setState(() {
      _dragOffset = 0.0;
      _isDragging = false;
    });
  }

  void _handleSwipe(double dragDistance, double velocity) {
    final bool isFastSwipe = velocity.abs() > _swipeVelocityThreshold;
    final bool isFarSwipe = dragDistance.abs() > _swipeThreshold;

    if (isFarSwipe || isFastSwipe) {
      _onSwipeComplete(dragDistance > 0);
    } else {
      _resetPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragPercentage = _dragOffset / screenWidth;

    return GestureDetector(
      onTap: widget.onTap,
      onPanStart: (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dx;

          if (_dragOffset.abs() > _maxDragOffset) {
            _dragOffset = _dragOffset > 0 ? _maxDragOffset : -_maxDragOffset;
          }
        });
      },
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond.dx;
        _handleSwipe(_dragOffset, velocity);
      },
      onPanCancel: _resetPosition,
      child: Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: Transform.rotate(
          angle: dragPercentage *
              0.3,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isDragging
                  ? [
                      BoxShadow(
                        color: _dragOffset > 0
                            ? Colors.green
                                .withValues(alpha: 0.6 - dragPercentage.abs())
                            : Colors.red
                                .withValues(alpha: 0.6 - dragPercentage.abs()),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.catImage.url,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.pets,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  if (_isDragging && _dragOffset.abs() > 10)
                    Container(
                      color: _dragOffset > 0
                          ? Colors.green.withValues(alpha: 0.2 * dragPercentage)
                          : Colors.red
                              .withValues(alpha: 0.2 * dragPercentage.abs()),
                    ),

                  if (_isDragging && _dragOffset.abs() > 20)
                    Positioned(
                      top: 40,
                      left: _dragOffset > 0 ? 20 : null,
                      right: _dragOffset < 0 ? 20 : null,
                      child: AnimatedOpacity(
                        opacity: _dragOffset.abs() > 20 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _dragOffset > 0 ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _dragOffset > 0 ? Icons.favorite : Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _dragOffset > 0 ? 'ЛАЙК' : 'ДИЗЛАЙК',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (!_isDragging && _dragOffset == 0)
                    const Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Icon(
                            Icons.swipe,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Свайпните влево или вправо',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'или используйте кнопки ниже',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
