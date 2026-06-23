import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/map_viewmodel.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double borderWidth;
  final Color? customBgColor;
  final double? width;
  final double? height;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.blur = 12.0,
    this.borderWidth = 1.0,
    this.customBgColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<MapViewModel>().isDarkMode;

    final defaultBgColor = isDarkMode
        ? const Color(0xFF1E293B).withOpacity(0.70) // Slate dark glass
        : Colors.white.withOpacity(0.70); // White glass

    final defaultBorderColor = isDarkMode
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.25);

    final defaultShadow = isDarkMode
        ? BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        : BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: [defaultShadow],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: customBgColor ?? defaultBgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: defaultBorderColor,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
