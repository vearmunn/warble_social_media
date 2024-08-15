import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warble_social_media/controllers/database_controller.dart';
import 'package:warble_social_media/models/posts.dart';
import 'package:warble_social_media/pages/profile_page.dart';
import 'package:warble_social_media/pages/view_post_page.dart';
import 'package:warble_social_media/services/auth/auth_service.dart';
import 'package:warble_social_media/themes/colors.dart';
import 'package:warble_social_media/utils/custom_alert_dialog.dart';
import 'package:warble_social_media/widgets/my_drawer.dart';

import '../widgets/post_tile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseController c = Get.put(DatabaseController());
  final postController = TextEditingController();
  final _auth = AuthService();

  @override
  void initState() {
    c.getAllPosts();
    c.getAllComments();

    c.getUserInfo(_auth.getCurrentUserID());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: extraLightGrey,
          title: const Text(
            'W A R B L E',
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'For You',
              ),
              Tab(
                text: 'Following',
              ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  c.searchUsers('jo');
                  print(c.searchResults);
                },
                icon: const Icon(Icons.search))
          ],
        ),
        drawer: const MyDrawer(),
        backgroundColor: extraLightGrey,
        body: TabBarView(
          children: [
            _buildPostList(
                databaseController: c,
                list: c.allPosts,
                emptyListMesage: 'No Posts'),
            _buildPostList(
                databaseController: c,
                list: c.allFollowingPosts,
                emptyListMesage: 'No Posts'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: mainBlue,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => CustomAlertDialog(
                hint: "What's on your mind ?",
                onPressedText: 'Post',
                onTap: () {
                  Navigator.pop(context);
                  c.addPost(postController.text);
                  postController.clear();
                },
                controller: postController),
          ),
        ),
      ),
    );
  }

  Widget _buildPostList(
      {required DatabaseController databaseController,
      required RxList<Posts> list,
      required String emptyListMesage}) {
    return Obx(() {
      if (databaseController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (databaseController.errMessage.value != '') {
        return Center(child: Text(databaseController.errMessage.value));
      } else if (list.isEmpty) {
        return Center(child: Text(emptyListMesage));
      } else {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return PostTile(
                post: list[index],
                commentCounter: c.specificPostsComments[list[index].id]!.length,
                onUserTap: () {
                  c.getUserInfo(list[index].uid);
                  c.getFollowers(list[index].uid);
                  c.getFollowing(list[index].uid);
                  // c.getAllUserPosts(c.allPosts[index].uid);
                  Get.to(() => const ProfilePage());
                },
                onPostTap: () {
                  // c.getSpecificCommentsofPost(c.allPosts[index].id);
                  Get.to(() => ViewPostPage(post: list[index]));
                });
          },
        );
      }
    });
  }
}
