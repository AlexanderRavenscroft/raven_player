import 'package:flutter/material.dart';

class AppLinearProgressIndicator extends StatelessWidget {
  final double? value;
  final double? width;
  final double height;

  const AppLinearProgressIndicator({
    super.key,
    this.value,
    this.width,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: LinearProgressIndicator(
          value: value,
          minHeight: height,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
