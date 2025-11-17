import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/login_screen.dart';

/// Uygulama genelinde kullanılacak tema yöneticisi
/// (Settings ekranından değeri değiştireceğiz)
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Senin çalışan Firebase ayarların – hiçbirini değiştirmedim
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MySphereClean',
          themeMode: mode,
          theme: _lightTheme,
          darkTheme: _darkTheme,
          home: const LoginScreen(),
        );
      },
    );
  }
}

// -------------------- Tema Tanımları --------------------

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6A4ECF),
    brightness: Brightness.light,
    background: const Color(0xFFF3EFFC),
  ),
  scaffoldBackgroundColor: const Color(0xFFF3EFFC),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Colors.black87,
  ),
  useMaterial3: true,
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6A4ECF),
    brightness: Brightness.dark,
    background: const Color(0xFF000000),
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Colors.white,
  ),
  useMaterial3: true,
);
