import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final bool showBottomNav;
  final bool showAppBar;

  const BaseLayout({
    super.key,
    required this.child,
    this.showBottomNav = false,
    this.showAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text("Spotly")) : null,
      body: child,
      bottomNavigationBar: showBottomNav
          ? const SizedBox(
              height: 60,
              child: Center(child: Text("Bottom Nav")),
            )
          : null,
    );
  }
}