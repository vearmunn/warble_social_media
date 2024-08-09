// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../themes/colors.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    required this.hint,
    required this.onPressedText,
    required this.onTap,
    required this.controller,
  });

  final String hint;
  final String onPressedText;
  final VoidCallback onTap;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: darkGrey, width: 1)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: mainBlue, width: 1))),
        maxLength: 140,
        maxLines: 3,
      ),
      actions: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel')),
        TextButton(onPressed: onTap, child: Text(onPressedText)),
      ],
    );
  }
}
