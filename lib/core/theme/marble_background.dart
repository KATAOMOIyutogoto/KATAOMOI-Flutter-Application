import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class MarbleBackground extends StatefulWidget {
  final Widget child;
  final bool animated;
  
  const MarbleBackground({
    super.key,
    required this.child,
    this.animated = true,
  });

  @override
  State<MarbleBackground> createState() => _MarbleBackgroundState();
}

class _MarbleBackgroundState extends State<MarbleBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    
    if (widget.animated) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0B2E), // 深い紫
            Color(0xFF2D1B69), // 紫
            Color(0xFF0F0F23), // 深い黒
            Color(0xFF4A1A4A), // 明るい紫
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // マーブル模様のレイヤー
          Positioned.fill(
            child: widget.animated
                ? AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: MarblePainter(_animation.value),
                        size: Size.infinite,
                      );
                    },
                  )
                : CustomPaint(
                    painter: MarblePainter(0),
                    size: Size.infinite,
                  ),
          ),
          // 半透明のフィルターレイヤー
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          // コンテンツのレイヤー
          Positioned.fill(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class MarblePainter extends CustomPainter {
  final double animationValue;
  
  MarblePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.overlay;

    // マーブル模様の円を複数描画
    _drawMarbleCircles(canvas, size, paint);
  }

  void _drawMarbleCircles(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42); // 固定シードで一貫した模様
    
    for (int i = 0; i < 12; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 100 + random.nextDouble() * 150;
      
      // アニメーションに基づいて位置を微調整
      final offsetX = math.sin(animationValue + i * 0.5) * 20;
      final offsetY = math.cos(animationValue + i * 0.3) * 15;
      
      final gradient = RadialGradient(
        colors: [
          Colors.purple.withOpacity(0.4),
          Colors.deepPurple.withOpacity(0.2),
          Colors.purpleAccent.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
      
      paint.shader = gradient.createShader(
        Rect.fromCircle(
          center: Offset(x + offsetX, y + offsetY),
          radius: radius,
        ),
      );
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }
    
    // 追加の小さなマーブル模様
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 50 + random.nextDouble() * 80;
      
      final offsetX = math.cos(animationValue + i * 0.8) * 15;
      final offsetY = math.sin(animationValue + i * 0.6) * 12;
      
      final gradient = RadialGradient(
        colors: [
          Colors.indigo.withOpacity(0.3),
          Colors.blue.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      
      paint.shader = gradient.createShader(
        Rect.fromCircle(
          center: Offset(x + offsetX, y + offsetY),
          radius: radius,
        ),
      );
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }
  }


  @override
  bool shouldRepaint(MarblePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
