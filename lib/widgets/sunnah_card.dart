import 'package:flutter/material.dart';
import '../models/sunnah_item.dart';
import '../services/sunnah_api_service.dart';

class SunnahCard extends StatefulWidget {
  final SunnahItem item;
  final VoidCallback onToggle;
  final VoidCallback onInfo;

  const SunnahCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onInfo,
  });

  @override
  State<SunnahCard> createState() => _SunnahCardState();
}

class _SunnahCardState extends State<SunnahCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    switch (widget.item.category) {
      case 'Ibadah':
        return const Color(0xFF9B87E8);
      case 'Amalan':
        return const Color(0xFFE89B87);
      case 'Kebersihan':
        return const Color(0xFF87C4E8);
      case 'Adab':
        return const Color(0xFFE887C4);
      case 'Kebiasaan':
        return const Color(0xFFB8E887);
      default:
        return const Color(0xFF9B87E8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final starCount = SunnahApiService.getStarCount(widget.item.streakDays);
    final stars = SunnahApiService.getStarEmoji(starCount);
    final categoryColor = _getCategoryColor();
    final hasStreak = widget.item.streakDays > 0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: starCount > 0
                  ? const Color(0xFFFFD88A)
                  : categoryColor.withOpacity(0.15),
              width: starCount > 0 ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: starCount > 0
                    ? const Color(0xFFFFD88A).withOpacity(0.12)
                    : categoryColor.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Subtle Background Pattern
                if (starCount > 0)
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFFD88A).withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: starCount > 0
                                ? [const Color(0xFFFFF5E1), const Color(0xFFFFEDCC)]
                                : [
                                    categoryColor.withOpacity(0.08),
                                    categoryColor.withOpacity(0.04),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: starCount > 0
                                ? const Color(0xFFFFD88A).withOpacity(0.3)
                                : categoryColor.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.item.icon,
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Content Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              widget.item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2A3D),
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: categoryColor.withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                widget.item.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: categoryColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Streak Info
                            Row(
                              children: [
                                if (starCount > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFF5E1), Color(0xFFFFEDCC)],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFFFD88A).withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      stars,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: hasStreak
                                        ? const Color(0xFFFFEDCC).withOpacity(0.5)
                                        : const Color(0xFFF5F4F7),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: hasStreak
                                          ? const Color(0xFFFFD88A).withOpacity(0.3)
                                          : const Color(0xFFE8E6EF),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.local_fire_department_rounded,
                                        size: 14,
                                        color: hasStreak
                                            ? const Color(0xFFE89B87)
                                            : const Color(0xFFB8B5C3),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${widget.item.streakDays} hari',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          color: hasStreak
                                              ? const Color(0xFFE89B87)
                                              : const Color(0xFFB8B5C3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Actions Column
                      Column(
                        children: [
                          // Info Button
                          GestureDetector(
                            onTap: widget.onInfo,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: categoryColor.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                color: categoryColor,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // Checkbox
                          GestureDetector(
                            onTap: widget.onToggle,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: widget.item.isCompleted
                                    ? const LinearGradient(
                                        colors: [Color(0xFF87C4E8), Color(0xFFA5D5F0)],
                                      )
                                    : null,
                                color: widget.item.isCompleted
                                    ? null
                                    : const Color(0xFFF5F4F7),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: widget.item.isCompleted
                                      ? const Color(0xFF87C4E8)
                                      : const Color(0xFFE8E6EF),
                                  width: 1.5,
                                ),
                                boxShadow: widget.item.isCompleted
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF87C4E8).withOpacity(0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                widget.item.isCompleted
                                    ? Icons.check_rounded
                                    : Icons.circle_outlined,
                                color: widget.item.isCompleted
                                    ? Colors.white
                                    : const Color(0xFFB8B5C3),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}