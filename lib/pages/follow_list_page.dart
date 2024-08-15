// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:warble_social_media/controllers/database_controller.dart';
import 'package:warble_social_media/pages/profile_page.dart';

import '../models/user_profile.dart';
import '../themes/colors.dart';

class FollowListPage extends StatelessWidget {
  const FollowListPage({
    super.key,
    required this.initIndex,
  });
  final int initIndex;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DatabaseController>();
    return DefaultTabController(
      length: 2,
      initialIndex: initIndex,
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: extraLightGrey,
          title: const Text('FOLLOW LIST'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Followers',
              ),
              Tab(
                text: 'Following',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFollowList(
                databaseController: c,
                list: c.followerProfiles,
                emptyListMesage: 'No Followers'),
            _buildFollowList(
                databaseController: c,
                list: c.followingProfiles,
                emptyListMesage: 'No Following'),
          ],
        ),
      ),
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
      } else if (list.isEmpty) {
        return Center(child: Text(emptyListMesage));
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
          ),
        );
      }
    });
  }
}
