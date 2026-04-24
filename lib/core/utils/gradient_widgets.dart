import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.gradient = AppColors.primaryGradient,
    this.padding,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final LinearGradient gradient;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppColors.primaryGradient,
  });

  final String text;
  final TextStyle? style;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(text, style: style),
    );
  }
}
