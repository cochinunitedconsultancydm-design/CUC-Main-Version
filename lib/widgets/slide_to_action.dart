import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cuc_app/theme.dart';

class SlideToAction extends StatefulWidget {
  final String text;
  final VoidCallback onAction;
  final Color trackColor;
  final Color thumbColor;
  final IconData thumbIcon;

  const SlideToAction({
    super.key,
    required this.text,
    required this.onAction,
    this.trackColor = AppTheme.primaryColor,
    this.thumbColor = Colors.white,
    this.thumbIcon = Icons.arrow_forward_ios,
  });

  @override
  State<SlideToAction> createState() => _SlideToActionState();
}

class _SlideToActionState extends State<SlideToAction> with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isCompleted = false;
  final double _trackHeight = 60.0;
  final double _thumbSize = 52.0;

  void _onHorizontalDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (_isCompleted) return;
    
    setState(() {
      _dragPosition += details.delta.dx;
      // Clamp between 0 and (trackWidth - thumb padding)
      final maxDrag = trackWidth - _thumbSize - 8.0;
      if (_dragPosition < 0) _dragPosition = 0;
      if (_dragPosition > maxDrag) {
        _dragPosition = maxDrag;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double trackWidth) {
    if (_isCompleted) return;
    
    final maxDrag = trackWidth - _thumbSize - 8.0;
    if (_dragPosition >= maxDrag * 0.85) { // 85% threshold to trigger
      setState(() {
        _dragPosition = maxDrag;
        _isCompleted = true;
      });
      widget.onAction();
    } else {
      // Snap back to 0
      setState(() {
        _dragPosition = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        return Container(
          height: _trackHeight,
          width: trackWidth,
          decoration: BoxDecoration(
            color: widget.trackColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(_trackHeight / 2),
            border: Border.all(color: widget.trackColor.withOpacity(0.3)),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Text in the center
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: _thumbSize),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.trackColor.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2000.ms, color: widget.trackColor.withOpacity(0.5)),
                ),
              ),
              
              // Progress track fill
              AnimatedContainer(
                duration: _dragPosition == 0 ? 300.ms : 0.ms,
                curve: Curves.easeOut,
                height: _trackHeight,
                width: _dragPosition + _thumbSize + 4.0,
                decoration: BoxDecoration(
                  color: widget.trackColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(_trackHeight / 2),
                ),
              ),

              // Draggable Thumb
              AnimatedPositioned(
                duration: _dragPosition == 0 ? 300.ms : 0.ms,
                curve: Curves.easeOut,
                left: _dragPosition + 4.0,
                top: 3.0,
                bottom: 3.0,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, trackWidth),
                  onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, trackWidth),
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: widget.trackColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.trackColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _isCompleted 
                      ? const Icon(Icons.check, color: Colors.white, size: 28)
                      : Icon(widget.thumbIcon, color: widget.thumbColor, size: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
