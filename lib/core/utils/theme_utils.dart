import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context/theme_context.dart';

class ThemeUtils {
  static bool isDark(BuildContext context) {
    return Provider.of<ThemeProvider>(context).isDark;
  }

  static void toggle(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }
}