import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warble_social_media/controllers/database_controller.dart';
import 'package:warble_social_media/pages/blocked_users_page.dart';
import 'package:warble_social_media/utils/spacer.dart';

import '../themes/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DatabaseController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: extraLightGrey,
        title: const Text(
          'S E T T I N G S',
        ),
        centerTitle: true,
      ),
      backgroundColor: extraLightGrey,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () {
              c.getBlockedUsersData();
              Get.to(() => const BlockedUsersPage());
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.block),
                      horizontalSpacer(16),
                      const Text(
                        'Blocked Users',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
