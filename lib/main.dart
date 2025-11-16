import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const FirebaseInitWrapper(),
    );
  }
}

/// Uygulama açılırken önce Firebase'i başlatıyoruz.
/// Hata olursa ekranda hata mesajını göreceksin, siyah ekran olmayacak.
class FirebaseInitWrapper extends StatelessWidget {
  const FirebaseInitWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Yükleniyor
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Hata olduysa ekrana yaz
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Bir hata oluştu:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // Her şey yolundaysa giriş ekranına geç
        return const LoginScreen();
      },
    );
  }
}
