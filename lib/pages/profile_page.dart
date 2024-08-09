// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:warble_social_media/controllers/database_controller.dart';
import 'package:warble_social_media/utils/custom_alert_dialog.dart';
import 'package:warble_social_media/utils/spacer.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: extraLightGrey,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Icon(Icons.arrow_back),
                        ),
                        GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Wrap(
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              CustomAlertDialog(
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
                                    ),
                                    ListTile(
                                      onTap: () => Navigator.pop(context),
                                      leading: const Icon(Icons.cancel),
                                      title: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Icon(Icons.more_horiz)),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: mainBlue,
                      radius: 50,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 55,
                      ),
                    ),
                    verticalSpacer(16),
                    Obx(() => c.isLoading.value
                        ? const Text('...')
                        : Center(
                            child: Text(
                            c.userInfo.value.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ))),
                    Center(
                        child: Obx(
                      () => c.isLoading.value
                          ? const Text('...')
                          : Text(
                              '@${c.userInfo.value.username}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: darkGrey),
                            ),
                    )),
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
                                    ViewPostPage(post: c.allPosts[index])),
                                onUserTap: () {},
                                name: c.allUserPosts[index].name,
                                username: c.allUserPosts[index].username,
                                post: c.allUserPosts[index].message,
                              );
                            },
                          ),
              )
            ],
          ),
        ));
  }
}
