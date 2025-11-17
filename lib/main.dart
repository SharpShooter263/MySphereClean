import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; // HomeScreen içinde kullanılıyor olabilir

// Eğer firebase_options.dart kullanıyorsan bu importu da aç:
// import 'firebase_options.dart';

/// Uygulama genelinde temayı yöneten notifier.
/// SettingsScreen buraya erişip ThemeMode'u değiştiriyor.
final ValueNotifier<ThemeMode> appThemeMode =
    ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Eğer projende daha önce:
  // Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // kullanıyorsan aşağıdaki satırı yorum satırına alıp
  // kendi kullandığın initialize satırını ekleyebilirsin.
  await Firebase.initializeApp();

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
          title: 'MySphere',
          themeMode: mode,

          // AÇIK TEMA
          theme: ThemeData(
            useMaterial3: false,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6A4ECF),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF3EFFC),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.black87,
            ),
          ),

          // KOYU TEMA
          darkTheme: ThemeData(
            useMaterial3: false,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6A4ECF),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
          ),

          // HomeScreen kendi içinde kullanıcı login mi değil mi kontrol ediyor.
          home: const HomeScreen(),
        );
      },
    );
  }
}
