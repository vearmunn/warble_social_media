import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warble_social_media/controllers/database_controller.dart';

import '../themes/colors.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DatabaseController>();

    void showAlertDialog(String uid, String name) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('Are you sure you want to unblock this user?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  c.unblockUser(uid, name);
                },
                child: const Text('Unblock'))
          ],
        ),
      );
    }

    void showModalOptions(String uid, String name) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.block_flipped),
              title: const Text('Unblock user'),
              onTap: () {
                Navigator.pop(context);
                showAlertDialog(uid, name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: extraLightGrey,
        title: const Text(
          'BLOCKED USERS',
        ),
        centerTitle: true,
      ),
      backgroundColor: extraLightGrey,
      body: Obx(
        () => c.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : c.blockedUserList.isEmpty
                ? const Center(
                    child: Text('No blocked users'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: c.blockedUserList.length,
                    itemBuilder: (BuildContext context, int index) {
                      // final user = c.blockedUserList[index];
                      return ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        leading: CircleAvatar(
                          backgroundColor: mainBlue,
                        ),
                        title: Text(c.blockedUserList[index].name),
                        subtitle: Text(
                          '@${c.blockedUserList[index].username}',
                          style: TextStyle(color: darkGrey),
                        ),
                        trailing: const Icon(Icons.more_vert),
                        onTap: () {
                          showModalOptions(c.blockedUserList[index].uid,
                              c.blockedUserList[index].name);
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
