import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/role_select_screen.dart';
import 'theme.dart';
import 'widgets/app_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AttendanceApp());
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'your_api_key',
      appId: 'your_app_id',
      messagingSenderId: 'your_messaging_sender_id',
      projectId: 'your_project_id',
    );
  }
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Checker',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      builder: (context, child) => AppBackground(child: child!),
      home: const RoleSelectScreen(),
    );
  }
}