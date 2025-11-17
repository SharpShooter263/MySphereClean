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
    final User? user = _auth.currentUser;

    // Kullanıcı yoksa Login'e at
    if (user == null) {
      return const LoginScreen();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Veri yüklenirken basit bir loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF3EFFC),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Doküman yoksa yine Login'e at (olağanüstü durum)
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const LoginScreen();
        }

        final data = snapshot.data!.data() ?? {};

        final String name = (data['name'] ?? '') as String;
        final String email = (data['email'] ?? user.email ?? '') as String;

        final List<dynamic> links = (data['links'] as List<dynamic>?) ?? [];

        final int views = (data['views'] ?? 0) as int;
        final int shares = (data['shares'] ?? 0) as int;
        final bool darkMode = (data['darkMode'] ?? false) as bool;

        final int connectionsCount = links.length;

        // Basit bir profil URL'si (ileride gerçek web sayfasına gidecek)
        final String profileUrl = "https://mysphere.app/u/${user.uid}";

        // Tema renkleri
        final bgColor =
            darkMode ? const Color(0xFF121212) : const Color(0xFFF3EFFC);
        final cardColor =
            darkMode ? const Color(0xFF1E1E1E) : Colors.white;
        final primaryTextColor =
            darkMode ? Colors.white : Colors.black87;
        final secondaryTextColor =
            darkMode ? Colors.white70 : Colors.black54;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: primaryTextColor),
            title: Text(
              "MySphere",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: primaryTextColor),
                onPressed: () async {
                  await _auth.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
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
                      // ÜST BÖLÜM
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  const Color(0xFFDCD4FF).withOpacity(
                                      darkMode ? 0.4 : 1),
                              child: const Icon(
                                Icons.person,
                                size: 32,
                                color: Color(0xFF6A4ECF),
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
                                    color: primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name.isNotEmpty ? name : email,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        "Hızlı İşlemler",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // KUTULAR
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        children: [
                          buildMenuCard(
                            icon: Icons.person,
                            title: "Profilim",
                            subtitle: "Bilgilerini düzenle",
                            cardColor: cardColor,
                            textColor: primaryTextColor,
                            subtitleColor: secondaryTextColor,
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
                            icon: Icons.link,
                            title: "Linklerim",
                            subtitle: "Sosyal medya ekle",
                            cardColor: cardColor,
                            textColor: primaryTextColor,
                            subtitleColor: secondaryTextColor,
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
                            icon: Icons.qr_code,
                            title: "QR Paylaş",
                            subtitle: "Profilini göster",
                            cardColor: cardColor,
                            textColor: primaryTextColor,
                            subtitleColor: secondaryTextColor,
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
                            icon: Icons.settings,
                            title: "Ayarlar",
                            subtitle: "Tercihleri düzenle",
                            cardColor: cardColor,
                            textColor: primaryTextColor,
                            subtitleColor: secondaryTextColor,
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

                      Text(
                        "Aktivite Özeti",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            summaryItem(
                              connectionsCount.toString(),
                              "Bağlantı",
                              primaryTextColor,
                              secondaryTextColor,
                            ),
                            summaryItem(
                              views.toString(),
                              "Görüntüleme",
                              primaryTextColor,
                              secondaryTextColor,
                            ),
                            summaryItem(
                              shares.toString(),
                              "Paylaşım",
                              primaryTextColor,
                              secondaryTextColor,
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

  static Widget summaryItem(
    String number,
    String title,
    Color numberColor,
    Color labelColor,
  ) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: numberColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(color: labelColor),
        ),
      ],
    );
  }

  Widget buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: const Color(0xFF6A4ECF)),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: subtitleColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
