import 'package:flutter/material.dart';

class NotebookPage extends StatelessWidget {
  final Widget child;
  final bool showLines;

  const NotebookPage({
    super.key,
    required this.child,
    this.showLines = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF4),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(2, 5),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (showLines)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: NotebookLinePainter(),
                ),
              ),
            ),
          Positioned(
            left: 52,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: const Color(0xFFE1B7B7),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 78,
              right: 28,
              top: 28,
              bottom: 28,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class NotebookLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E1D5)
      ..strokeWidth = 1;

    const lineSpacing = 30.0;

    for (
      double y = 28;
      y < size.height;
      y += lineSpacing
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}