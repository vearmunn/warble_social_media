// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:warble_social_media/controllers/database_controller.dart';
import 'package:warble_social_media/pages/follow_list_page.dart';
import 'package:warble_social_media/services/auth/auth_service.dart';
import 'package:warble_social_media/utils/custom_alert_dialog.dart';
import 'package:warble_social_media/utils/spacer.dart';
import 'package:warble_social_media/widgets/my_button.dart';

import '../themes/colors.dart';
import '../widgets/post_tile.dart';
import 'view_post_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final c = Get.find<DatabaseController>();
  final bioController = TextEditingController();
  final currentUid = AuthService().getCurrentUserID();

  @override
  Widget build(BuildContext context) {
    void showOptions() {
      showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
          children: [
            if (c.userInfo.value.uid == currentUid)
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => CustomAlertDialog(
                      hint: 'Update your bio...',
                      controller: bioController,
                      onPressedText: 'Save',
                      onTap: () {
                        Navigator.pop(context);
                        c.updateBio(bioController.text);
                        bioController.clear();
                      },
                    ),
                  );
                },
                leading: const Icon(Icons.edit_note),
                title: const Text('Update Bio'),
              )
            else ...[
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.report),
                title: const Text('Report'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.block),
                title: const Text('Block'),
              ),
            ],
            ListTile(
              onTap: () => Navigator.pop(context),
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
        backgroundColor: extraLightGrey,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BACK BUTTON AND MORE BUTTON ---------------------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            c.getAllPosts();
                            Get.back();
                          },
                          child: const Icon(Icons.arrow_back),
                        ),
                        GestureDetector(
                            onTap: showOptions,
                            child: const Icon(Icons.more_horiz)),
                      ],
                    ),

                    // AVATAR, FOLLOWERS, FOLLOWING ---------------------------------------------------------------------
                    verticalSpacer(16),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: mainBlue,
                          radius: 50,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 55,
                          ),
                        ),
                        horizontalSpacer(16),
                        Expanded(
                          child: Column(
                            children: [
                              Obx(
                                () => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        c.loadFollowerPorfiles(
                                            c.userInfo.value.uid);
                                        c.loadFollowingPorfiles(
                                            c.userInfo.value.uid);
                                        Get.to(() => const FollowListPage(
                                              initIndex: 0,
                                            ));
                                      },
                                      child: UserInfo(
                                        count: c.isLoading.value
                                            ? '...'
                                            : c.followersCount[
                                                    c.userInfo.value.uid]
                                                .toString(),
                                        label: 'Followers',
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        c.loadFollowerPorfiles(
                                            c.userInfo.value.uid);
                                        c.loadFollowingPorfiles(
                                            c.userInfo.value.uid);
                                        Get.to(() => const FollowListPage(
                                              initIndex: 1,
                                            ));
                                      },
                                      child: UserInfo(
                                        count: c.isLoading.value
                                            ? '...'
                                            : c.followingCount[
                                                    c.userInfo.value.uid]
                                                .toString(),
                                        label: 'Following',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              verticalSpacer(16),
                              Obx(
                                () => c.isLoading.value
                                    ? const SizedBox.shrink()
                                    : c.userInfo.value.uid == currentUid
                                        ? verticalSpacer(0)
                                        : MyButton(
                                            text: c.isFollowing.value
                                                ? 'Unfollow'
                                                : 'Follow',
                                            onTap: () {
                                              // c.getIsFollowing(
                                              //     c.userInfo.value.uid);
                                              if (c.isFollowing.value) {
                                                c.unfollowUser(
                                                    c.userInfo.value.uid);
                                              } else {
                                                c.followUser(
                                                    c.userInfo.value.uid);
                                              }
                                            },
                                            padding: 8,
                                            textColor: mainBlue,
                                            bgColor: const Color.fromARGB(
                                                104, 155, 187, 212),
                                          ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),

                    // NAME AND USERNAME ---------------------------------------------------------------
                    verticalSpacer(16),
                    Obx(() => c.isLoading.value
                        ? const Text('...')
                        : Text(
                            c.userInfo.value.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                    Obx(
                      () => c.isLoading.value
                          ? const Text('...')
                          : Text(
                              '@${c.userInfo.value.username}',
                              style: TextStyle(color: darkGrey),
                            ),
                    ),

                    // BIO ---------------------------------------------------------------------
                    verticalSpacer(20),
                    Obx(() => c.isLoading.value
                        ? const Text('...')
                        : SizedBox(
                            width: double.infinity,
                            child: Text(
                              c.userInfo.value.bio.isEmpty
                                  ? 'Empty Bio..'
                                  : c.userInfo.value.bio,
                              textAlign: TextAlign.left,
                            ),
                          ))
                  ],
                ),
              ),

              // POSTS ---------------------------------------------------------------------------
              verticalSpacer(30),
              Text(
                'Posts',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: darkGrey),
              ),
              verticalSpacer(12),
              Obx(
                () => c.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : c.allUserPosts.isEmpty
                        ? const Center(child: Text('No Posts'))
                        : ListView.builder(
                            itemCount: c.allUserPosts.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return PostTile(
                                onPostTap: () => Get.to(() =>
                                    ViewPostPage(post: c.allUserPosts[index])),
                                onUserTap: () {},
                                post: c.allUserPosts[index],
                                commentCounter: c
                                    .specificPostsComments[
                                        c.allUserPosts[index].id]!
                                    .length,
                              );
                            },
                          ),
              )
            ],
          ),
        ));
  }
}

class UserInfo extends StatelessWidget {
  const UserInfo({
    super.key,
    required this.label,
    required this.count,
  });
  final String label;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          label,
          style: TextStyle(color: darkGrey),
        ),
      ],
    );
  }
}
