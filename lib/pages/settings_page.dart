import 'package:flutter/material.dart';

import '../themes/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: extraLightGrey,
        title: const Text(
          'S E T T I N G S',
        ),
        centerTitle: true,
      ),
    );
  }
}
