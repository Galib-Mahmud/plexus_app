import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? borderColor;
  final double blur;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.borderColor,
    this.blur = 18,
    this.boxShadow,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ?? LinearGradient(
              colors: [Colors.white.withOpacity(0.10), Colors.white.withOpacity(0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: borderRadius,
            border: Border.all(color: borderColor ?? AppColors.glassBorder, width: 1.0),
            boxShadow: boxShadow ?? [
              BoxShadow(color: Colors.black.withOpacity(0.30), blurRadius: 30, offset: const Offset(0, 10)),
            ],
          ),
          child: child,
        ),
      ),
    );
    if (onTap != null) return GestureDetector(onTap: onTap, child: content);
    return content;
  }
}

class GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const GlowOrb({super.key, required this.color, required this.size, this.opacity = 0.4});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withOpacity(opacity), color.withOpacity(0.0)]),
      ),
    );
  }
}

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color startColor;
  final Color endColor;
  final IconData? icon;
  final double height;

  const NeonButton({
    super.key, required this.label, this.onTap, this.isLoading = false,
    this.startColor = AppColors.neonBlue, this.endColor = AppColors.neonCyan,
    this.icon, this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading ? [startColor.withOpacity(0.3), endColor.withOpacity(0.3)] : [startColor, endColor],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading ? [] : [BoxShadow(color: endColor.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.bg0)))
              : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, color: AppColors.bg0, size: 18), const SizedBox(width: 8)],
            Text(label, style: const TextStyle(color: AppColors.bg0, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ]),
        ),
      ),
    );
  }
}

class StatusDot extends StatefulWidget {
  final bool isOnline;
  final double size;
  const StatusDot({super.key, required this.isOnline, this.size = 10});
  @override State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = widget.isOnline ? AppColors.neonGreen : AppColors.neonRed;
    if (!widget.isOnline) return Container(width: widget.size, height: widget.size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: widget.size, height: widget.size,
        decoration: BoxDecoration(
          color: color.withOpacity(_pulse.value), shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(_pulse.value * 0.7), blurRadius: widget.size * 1.8, spreadRadius: 1)],
        ),
      ),
    );
  }
}

class HexGridPainter extends CustomPainter {
  final Color color;
  HexGridPainter({this.color = const Color(0x07FFFFFF)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.5..style = PaintingStyle.stroke;
    const r = 22.0, h = r * 1.732, w = r * 2;
    for (double y = -h; y < size.height + h; y += h) {
      final row = (y / h).floor();
      for (double x = -w; x < size.width + w; x += w * 1.5) {
        _drawHex(canvas, paint, Offset(x + (row.isOdd ? w * 0.75 : 0), y), r);
      }
    }
  }

  void _drawHex(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * 60 - 30) * math.pi / 180;
      final p = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      if (i == 0) path.moveTo(p.dx, p.dy); else path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override bool shouldRepaint(_) => false;
}

class ScanlineOverlay extends StatelessWidget {
  const ScanlineOverlay({super.key});
  @override
  Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(painter: _ScanlinePainter(), size: Size.infinite));
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.012)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override bool shouldRepaint(_) => false;
}

class DataChip extends StatelessWidget {
  final String label;
  final Color color;
  const DataChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3), width: 0.8),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
  );
}
