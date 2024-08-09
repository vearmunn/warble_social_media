// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:warble_social_media/models/posts.dart';
import 'package:warble_social_media/widgets/post_tile.dart';

import '../controllers/database_controller.dart';
import '../themes/colors.dart';
import 'profile_page.dart';

class ViewPostPage extends StatelessWidget {
  const ViewPostPage({
    super.key,
    required this.post,
  });

  final Posts post;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DatabaseController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: extraLightGrey,
        title: Text(
          post.name,
        ),
        centerTitle: true,
      ),
      backgroundColor: extraLightGrey,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PostTile(
              name: post.name,
              username: post.username,
              post: post.message,
              onPostTap: () {},
              onUserTap: () {
                c.getUserInfo(post.uid);
                c.getAllUserPosts(post.uid);
                Get.to(() => const ProfilePage());
              })
        ],
      ),
    );
  }
}
