import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

/// Tema seçimi için (Settings ekranında kullanıyorduk)
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          // ⬇️ Artık doğrudan LoginScreen değil, önce AuthGate açılıyor
          home: const AuthGate(),
        );
      },
    );
  }
}

/// Kullanıcı oturumunu kontrol eden küçük widget
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase bağlanırken / auth durumu alınırken
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Kullanıcı varsa → HomeScreen
        if (snapshot.data != null) {
          return const HomeScreen();
        }

        // Kullanıcı yoksa → LoginScreen
        return const LoginScreen();
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
