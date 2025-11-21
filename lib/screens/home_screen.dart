import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'profile_screen.dart';
import 'links_screen.dart';
import 'qr_share_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final User? user = _auth.currentUser;

    // Kullanıcı yoksa Login'e gönder
    if (user == null) {
      return const LoginScreen();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Yükleniyor durumu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: colorScheme.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Doküman yoksa güvenlik amaçlı Login'e gönder
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const LoginScreen();
        }

        final data = snapshot.data!.data() ?? {};

        final String name = (data['name'] ?? '') as String;
        final String email = (data['email'] ?? user.email ?? '') as String;
        final List<dynamic> links =
            (data['links'] as List<dynamic>?) ?? const [];

        final int views = (data['views'] ?? 0) as int;
        final int shares = (data['shares'] ?? 0) as int;
        final int connectionsCount = links.length;

        // 🔗 Herkese açık profil linki (ileride gerçek domain ile güncelleriz)
        final String profileUrl =
            'https://mysphere.app/profile/${user.uid}';

        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              "MySphere",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            actions: [
              // Sağ üstte Ayarlar ikonu
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: colorScheme.onBackground,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              // Çıkış ikonu
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: colorScheme.onBackground,
                ),
                onPressed: () async {
                  await _auth.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========= ÜST KART =========
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                theme.brightness == Brightness.light
                                    ? 0.06
                                    : 0.3,
                              ),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Icon(
                                Icons.person,
                                size: 32,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hoş geldin 👋",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name.isNotEmpty ? name : email,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ========= HIZLI İŞLEMLER =========
                      Text(
                        "Hızlı İşlemler",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 15),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        children: [
                          buildMenuCard(
                            context: context,
                            icon: Icons.person,
                            title: "Profilim",
                            subtitle: "Bilgilerini düzenle",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                          ),
                          buildMenuCard(
                            context: context,
                            icon: Icons.link,
                            title: "Linklerim",
                            subtitle: "Sosyal medya ekle",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LinksScreen(),
                                ),
                              );
                            },
                          ),
                          buildMenuCard(
                            context: context,
                            icon: Icons.qr_code,
                            title: "QR Paylaş",
                            subtitle: "Profilini göster",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QRShareScreen(
                                    profileUrl: profileUrl,
                                  ),
                                ),
                              );
                            },
                          ),
                          buildMenuCard(
                            context: context,
                            icon: Icons.settings,
                            title: "Ayarlar",
                            subtitle: "Tercihleri düzenle",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ========= AKTİVİTE ÖZETİ =========
                      Text(
                        "Aktivite Özeti",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                theme.brightness == Brightness.light
                                    ? 0.06
                                    : 0.3,
                              ),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            summaryItem(
                              context,
                              connectionsCount.toString(),
                              "Bağlantı",
                            ),
                            summaryItem(
                              context,
                              views.toString(),
                              "Görüntüleme",
                            ),
                            summaryItem(
                              context,
                              shares.toString(),
                              "Paylaşım",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // --------- Alt widget'lar ---------

  static Widget summaryItem(
    BuildContext context,
    String number,
    String title,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.light ? 0.06 : 0.3,
              ),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
