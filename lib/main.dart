//lib/main.dart

// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// import 'firebase_options.dart';
import 'presentation/auth/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/appwrite/appwrite_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppwriteTest.testConnection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PasarKita',
      home: LoginPage(),
    );
  }
}