import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase'i doğrudan koddan başlatıyoruz
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAF0kljgHTOtLPbGbfIxIcEwd_N3dAXkpQ',
      appId: '1:740712283120:android:ff55a85f1ba71be655fb35',
      messagingSenderId: '740712283120',
      projectId: 'mysphereclean',
      storageBucket: 'mysphereclean.firebasestorage.app',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MySphereClean',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}
