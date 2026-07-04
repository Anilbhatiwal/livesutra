import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LiveSutraApp());
}

class LiveSutraApp extends StatelessWidget {
  const LiveSutraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LiveSutra',

      // 👇 Auto Login
      home: FirebaseAuth.instance.currentUser != null
          ? const MainScreen()
          : const WelcomeScreen(),
    );
  }
}