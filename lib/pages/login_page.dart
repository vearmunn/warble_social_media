// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:warble_social_media/controllers/auth_controller.dart';
import 'package:warble_social_media/themes/colors.dart';
import 'package:warble_social_media/utils/spacer.dart';

import '../widgets/auth_textfield.dart';
import '../widgets/my_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final AuthController c = Get.put(AuthController());
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/dove.png',
              color: mainBlue,
              height: 100,
            ),
            verticalSpacer(20),
            const Text(
              "Welcome to Warble!",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            verticalSpacer(30),
            AuthTextField(
              controller: emailController,
              hintText: 'Email',
              textInputType: TextInputType.emailAddress,
            ),
            verticalSpacer(20),
            AuthTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            verticalSpacer(30),
            Obx(
              () => c.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : MyButton(
                      text: 'LOGIN',
                      onTap: () {
                        c.loginUser(
                            emailController.text, passwordController.text);
                      },
                    ),
            ),
            verticalSpacer(30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      " Register",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: mainBlue),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
