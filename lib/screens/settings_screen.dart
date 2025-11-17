import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart'; // appThemeMode'a erişmek için

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _isDarkMode = appThemeMode.value == ThemeMode.dark;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snap = await _firestore.collection('users').doc(user.uid).get();
      final data = snap.data() ?? {};

      setState(() {
        _notificationsEnabled =
            (data['notificationsEnabled'] ?? true) as bool;
        // Dark mode bilgisini Firestore'dan okumak istersen:
        if (data.containsKey('darkMode')) {
          _isDarkMode = data['darkMode'] as bool;
          appThemeMode.value =
              _isDarkMode ? ThemeMode.dark : ThemeMode.light;
        }
      });
    } catch (_) {
      // Sessiz geçiyoruz, istersen Snackbar eklenebilir
    }
  }

  Future<void> _savePreferences() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'notificationsEnabled': _notificationsEnabled,
          'darkMode': _isDarkMode,
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Sessiz, istersen hata gösterilebilir
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary =
        isDark ? Colors.white : Colors.black87;
    final textSecondary =
        isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tercihlerini düzenle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Bildirimler + Karanlık tema kartı
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Column(
                children: [
                  // Bildirimler satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bildirimler',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Yeni bağlantı ve görüntüleme bildirimleri',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        activeColor: const Color(0xFF6A4ECF),
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          _savePreferences();
                        },
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Karanlık tema satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Karanlık tema',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isDarkMode
                                  ? 'Karanlık tema aktif'
                                  : 'Karanlık tema kapalı',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isDarkMode,
                        activeColor: const Color(0xFF6A4ECF),
                        onChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                          });

                          // 🔑 Tüm uygulamanın temasını değiştir
                          appThemeMode.value =
                              value ? ThemeMode.dark : ThemeMode.light;

                          _savePreferences();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Hakkında
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hakkında',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MySphere profil yönetim uygulaması',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
