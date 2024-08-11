// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:warble_social_media/controllers/database_controller.dart';
import 'package:warble_social_media/models/posts.dart';
import 'package:warble_social_media/pages/view_post_page.dart';
import 'package:warble_social_media/services/auth/auth_service.dart';
import 'package:warble_social_media/themes/colors.dart';
import 'package:warble_social_media/utils/custom_alert_dialog.dart';
import 'package:warble_social_media/utils/show_modal_bottom_options.dart';
import 'package:warble_social_media/utils/spacer.dart';

class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.onUserTap,
    required this.onPostTap,
    required this.post,
    required this.commentCounter,
    this.isAtViewPostPage = false,
  });

  final VoidCallback onUserTap;
  final VoidCallback onPostTap;
  final Posts post;
  final int commentCounter;
  final bool isAtViewPostPage;

  @override
  Widget build(BuildContext context) {
    String currentUId = AuthService().getCurrentUserID();
    bool isOwnPost = post.uid == currentUId;
    final DatabaseController c = Get.find<DatabaseController>();
    final commentController = TextEditingController();

    void showCommentDialog() {
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          controller: commentController,
          hint: 'Write comment...',
          onPressedText: 'Post',
          onTap: () {
            if (commentController.text.isNotEmpty) {
              Navigator.pop(context);
              c.addComment(post.id, commentController.text);
            }
          },
        ),
      );
    }

    return GestureDetector(
      onTap: onPostTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onUserTap,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: mainBlue,
                      ),
                      horizontalSpacer(16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '@${post.username}',
                            style: TextStyle(fontSize: 12, color: darkGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                    onTap: () => showModalBottomOptions(
                          context: context,
                          type: 'post',
                          isOwnPost: isOwnPost,
                          onPressedDelete: () {
                            Navigator.pop(context);
                            c.deletePost(post.id);
                          },
                          onPressedBlock: () {
                            Navigator.pop(context);
                            c.blockUser(post.uid);
                          },
                          onPressedReport: () {
                            Navigator.pop(context);
                            c.reportUser(post.uid, post.id, '');
                          },
                        ),
                    child: Icon(
                      Icons.more_horiz,
                      color: darkGrey,
                    ))
              ],
            ),
            verticalSpacer(16),
            Text(post.message),
            verticalSpacer(16),
            Row(
              children: [
                Obx(
                  () => PostFeedback(
                    icon: c.isPostLikedByCurrentUser(post.id)
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    iconColor: c.isPostLikedByCurrentUser(post.id)
                        ? Colors.red
                        : darkGrey,
                    counter: c.likedCounts[post.id] == 0
                        ? ''
                        : c.likedCounts[post.id].toString(),
                    onTap: () {
                      c.toggleLike(post.id);
                    },
                  ),
                ),
                horizontalSpacer(20),
                Obx(
                  () => PostFeedback(
                    icon: Icons.chat_bubble_outline,
                    iconColor: darkGrey,
                    counter: c.isLoading.value
                        ? '...'
                        : c.specificPostsComments[post.id]!.isEmpty
                            ? ''
                            : c.specificPostsComments[post.id]!.length
                                .toString(),
                    onTap: isAtViewPostPage
                        ? showCommentDialog
                        : () => Get.to(() => ViewPostPage(post: post)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PostFeedback extends StatelessWidget {
  const PostFeedback({
    super.key,
    required this.counter,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String counter;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
          horizontalSpacer(5),
          Text(counter)
        ],
      ),
    );
  }
}
