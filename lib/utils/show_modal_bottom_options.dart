import 'package:flutter/material.dart';

void showModalBottomOptions({
  required context,
  required bool isOwnPost,
  required String type,
  required VoidCallback onPressedDelete,
  required VoidCallback onPressedReport,
  required VoidCallback onPressedBlock,
}) {
  void showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning!'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onPressedBlock,
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning!'),
        content: const Text('Are you sure you want to report this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onPressedReport,
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning!'),
        content: Text('Are you sure you want to delete this $type ?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                showReportDialog();
              },
              child: const Text('No')),
          TextButton(onPressed: onPressedDelete, child: const Text('Yes')),
        ],
      ),
    );
  }

  showModalBottomSheet(
    context: context,
    builder: (context) => Wrap(
      children: [
        if (isOwnPost)
          ListTile(
            onTap: () {
              Navigator.pop(context);
              showDeleteDialog();
            },
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
          )
        else ...[
          ListTile(
            onTap: () {
              Navigator.pop(context);
              showReportDialog();
            },
            leading: const Icon(Icons.report),
            title: const Text('Report'),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              showBlockDialog();
            },
            leading: const Icon(Icons.block),
            title: const Text('Block'),
          )
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
