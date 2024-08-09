// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:warble_social_media/themes/colors.dart';
import 'package:warble_social_media/utils/spacer.dart';

class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.name,
    required this.username,
    required this.post,
    required this.onUserTap,
    required this.onPostTap,
  });

  final String name;
  final String username;
  final String post;
  final VoidCallback onUserTap;
  final VoidCallback onPostTap;

  @override
  Widget build(BuildContext context) {
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
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '@$username',
                            style: TextStyle(fontSize: 12, color: darkGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.more_horiz,
                      color: darkGrey,
                    ))
              ],
            ),
            verticalSpacer(16),
            Text(post)
          ],
        ),
      ),
    );
  }
}
