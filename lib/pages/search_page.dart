import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warble_social_media/controllers/database_controller.dart';

import '../models/user_profile.dart';
import '../themes/colors.dart';
import 'profile_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DatabaseController>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
            c.isSearching.value = false;
          },
        ),
        title: TextField(
          decoration: const InputDecoration(hintText: 'Search username...'),
          onChanged: (v) {
            if (v.isNotEmpty) {
              c.searchUsers(v);
            } else {
              c.searchUsers("");
            }
            print(c.searchResults);
          },
        ),
      ),
      body: _buildFollowList(
          databaseController: c,
          list: c.searchResults,
          emptyListMesage: 'No user found!'),
    );
  }

  Widget _buildFollowList(
      {required DatabaseController databaseController,
      required RxList<UserProfile> list,
      required String emptyListMesage}) {
    return Obx(() {
      if (databaseController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (databaseController.errMessage.value != '') {
        return Center(child: Text(databaseController.errMessage.value));
      } else if (list.isEmpty && databaseController.isSearching.value) {
        return Center(child: Text(emptyListMesage));
      } else if (list.isEmpty &&
          databaseController.isSearching.value == false) {
        return const SizedBox.shrink();
      } else {
        return ListView.separated(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                databaseController.getUserInfo(list[index].uid);
                databaseController.getFollowers(list[index].uid);
                databaseController.getFollowing(list[index].uid);
                Get.to(() => const ProfilePage());
              },
              leading: CircleAvatar(
                backgroundColor: mainBlue,
              ),
              title: Text(
                list[index].name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '@${list[index].username}',
                style: TextStyle(fontSize: 12, color: darkGrey),
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(
            indent: 20,
            endIndent: 20,
            color: Colors.grey,
          ),
        );
      }
    });
  }
}
