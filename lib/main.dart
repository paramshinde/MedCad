import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    debugPrint('Firebase initialization error: $e\n$st');
  }

  try {
    await NotificationService.init();
  } catch (e, st) {
    debugPrint('NotificationService.init() error: $e\n$st');
  }

  runApp(const MedCodeApp());
}

class MedCodeApp extends StatelessWidget {
  const MedCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedCode',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), //  ROLE-BASED ENTRY POINT
    );
  }
}
