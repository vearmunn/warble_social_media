import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warble_social_media/firebase_options.dart';
import 'package:warble_social_media/services/auth/auth_gate.dart';
import 'package:warble_social_media/themes/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warble Social Media',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: mainBlue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
