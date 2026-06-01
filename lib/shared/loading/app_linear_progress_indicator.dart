import 'package:flutter/material.dart';

class AppLinearProgressIndicator extends StatelessWidget {
  const AppLinearProgressIndicator({
    super.key,
    this.value,
    this.width,
    this.height = 6,
  });

  final double? value;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: LinearProgressIndicator(
          value: value,
          minHeight: height,
          color: colorScheme.primary,
          backgroundColor: colorScheme.secondary,
        ),
      ),
    );
  }
}
