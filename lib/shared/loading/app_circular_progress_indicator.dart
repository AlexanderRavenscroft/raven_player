import 'package:flutter/material.dart';

class AppCircularProgressIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const AppCircularProgressIndicator({
    super.key,
    this.size = 50,
    this.strokeWidth = 4,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
