import 'package:flutter/material.dart';

class SpotlyUI {
  static void toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}