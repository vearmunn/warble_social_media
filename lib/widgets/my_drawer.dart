import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warble_social_media/controllers/database_controller.dart';
import 'package:warble_social_media/pages/profile_page.dart';
import 'package:warble_social_media/pages/search_page.dart';
import 'package:warble_social_media/pages/settings_page.dart';
import 'package:warble_social_media/services/auth/auth_service.dart';
import 'package:warble_social_media/utils/spacer.dart';

import '../controllers/auth_controller.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController ac = Get.find<AuthController>();
    final DatabaseController dbc = Get.find<DatabaseController>();
    final auth = AuthService();
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
              child: SizedBox(
            width: 50,
            height: 50,
            child: Image.asset(
              'assets/images/dove.png',
              color: Colors.black87,
            ),
          )),
          verticalSpacer(30),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('H O M E'),
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('S E T T I N G S'),
            onTap: () {
              Get.back();
              Get.to(() => const SettingsPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('P R O F I L E'),
            onTap: () {
              Get.back();
              dbc.getUserInfo(auth.getCurrentUserID());
              dbc.getFollowers(auth.getCurrentUserID());
              dbc.getFollowing(auth.getCurrentUserID());
              // dbc.getAllUserPosts(auth.getCurrentUserID());
              Get.to(() => const ProfilePage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('S E A R C H'),
            onTap: () {
              Get.back();

              Get.to(() => const SearchPage());
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('L O G O U T'),
            onTap: () {
              ac.logoutUser();
            },
          ),
          verticalSpacer(20)
        ],
      ),
    );
  }
}
