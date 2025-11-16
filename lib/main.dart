import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MySphereApp());
}

class MySphereApp extends StatelessWidget {
  const MySphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: const Color(0xFF3F51B5),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5FF),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}
