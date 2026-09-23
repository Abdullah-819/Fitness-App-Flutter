import 'package:flutter/material.dart';

import 'walkthrough_screen.dart';

/// Explicit screen for Walkthrough 1 (2_Light_walkthrough 1.png).
class WalkthroughOneScreen extends StatelessWidget {
  const WalkthroughOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalkthroughScreen(initialPage: 0);
  }
}
