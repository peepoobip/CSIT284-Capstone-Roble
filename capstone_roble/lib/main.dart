import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/role_select_screen.dart';
import 'theme.dart';
import 'widgets/app_background.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

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
      apiKey: 'AIzaSyCq9tLBfvazaVS4iehuUfRrws4ad6uJ1sc',
      authDomain: 'capstone-roble.firebaseapp.com',
      databaseURL:
          'https://capstone-roble-default-rtdb.asia-southeast1.firebasedatabase.app',
      projectId: 'capstone-roble',
      storageBucket: 'capstone-roble.firebasestorage.app',
      messagingSenderId: '709419483005',
      appId: '1:709419483005:web:b60874a633b35f65469614',
      measurementId: 'G-NJVTB34H3T',
    );
  }
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Attendance Checker',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: mode,
          builder: (context, child) => AppBackground(child: child!),
          home: const RoleSelectScreen(),
        );
      },
    );
  }
}