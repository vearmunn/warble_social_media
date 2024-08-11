// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:warble_social_media/models/posts.dart';
import 'package:warble_social_media/utils/spacer.dart';
import 'package:warble_social_media/widgets/post_tile.dart';

import '../controllers/database_controller.dart';
import '../models/comment.dart';
import '../services/auth/auth_service.dart';
import '../themes/colors.dart';
import '../utils/show_modal_bottom_options.dart';
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
              post: post,
              isAtViewPostPage: true,
              commentCounter: c.specificPostsComments[post.id]!.length,
              onPostTap: () {},
              onUserTap: () {
                c.getUserInfo(post.uid);
                c.getAllUserPosts(post.uid);
                Get.to(() => const ProfilePage());
              }),
          Text(
            'Comments',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: darkGrey, fontSize: 16),
          ),
          verticalSpacer(16),
          Obx(() {
            if (c.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (c.specificPostsComments[post.id]!.isEmpty) {
              return const Text('No Comments');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: c.specificPostsComments[post.id]!.length,
              itemBuilder: (BuildContext context, int index) {
                final comment = c.specificPostsComments[post.id]![index];
                return CommentTile(
                  comment: comment,
                  c: c,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.c,
  });

  final Comment comment;
  final DatabaseController c;

  @override
  Widget build(BuildContext context) {
    String currentUId = AuthService().getCurrentUserID();
    bool isOwnPost = comment.uid == currentUId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: mainBlue,
          ),
          horizontalSpacer(16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text('@${comment.username}',
                              style: TextStyle(fontSize: 12, color: darkGrey)),
                        ],
                      ),
                      GestureDetector(
                          onTap: () => showModalBottomOptions(
                                context: context,
                                type: 'comment',
                                isOwnPost: isOwnPost,
                                onPressedDelete: () {
                                  Navigator.pop(context);
                                  c.deleteComment(comment.id);
                                },
                                onPressedBlock: () {
                                  Navigator.pop(context);
                                  c.blockUser(comment.uid);
                                },
                                onPressedReport: () {
                                  Navigator.pop(context);
                                  c.reportUser(comment.uid, '', comment.id);
                                },
                              ),
                          child: Icon(
                            Icons.more_horiz,
                            color: darkGrey,
                          ))
                    ],
                  ),
                  verticalSpacer(16),
                  Text(comment.message),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
