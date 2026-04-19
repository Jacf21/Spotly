import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../themes/spotly_colors.dart';

class SpotlyLoader extends StatelessWidget {
  final bool dark;
  final String? message;

  const SpotlyLoader({super.key, required this.dark, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: SpotlyColors.accent(dark),
          ).animate().shimmer(),
          if (message != null) Text(message!)
        ],
      ),
    );
  }
}