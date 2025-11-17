import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'profile_screen.dart';
import 'links_screen.dart'; // ⬅️ YENİ: Linklerim ekranı

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userEmail = user.email ?? "";
      });

      // Firestore'dan kullanıcı bilgilerini çek
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          userName = snapshot["name"] ?? "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "MySphere",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST BÖLÜM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFDCD4FF),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFF6A4ECF),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hoş geldin 👋",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName.isNotEmpty ? userName : userEmail,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Hızlı İşlemler",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // KUTULAR
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                children: [
                  // Profilim kartı → Profil ekranına gider
                  buildMenuCard(
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

                  // Linklerim kartı → Link ekranına gider
                  buildMenuCard(
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

                  // QR Paylaş (şimdilik boş, sonra dolduracağız)
                  buildMenuCard(
                    icon: Icons.qr_code,
                    title: "QR Paylaş",
                    subtitle: "Profilini göster",
                    onTap: () {
                      // TODO: QR ekranı daha sonra
                    },
                  ),

                  // Ayarlar (şimdilik boş)
                  buildMenuCard(
                    icon: Icons.settings,
                    title: "Ayarlar",
                    subtitle: "Tercihleri düzenle",
                    onTap: () {
                      // TODO: Ayarlar ekranı daha sonra
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Aktivite Özeti",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _SummaryItem(number: "0", title: "Bağlantı"),
                  _SummaryItem(number: "0", title: "Görüntüleme"),
                  _SummaryItem(number: "0", title: "Paylaşım"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Özet kutusu (alt beyaz kutudaki sayılar)
  static const TextStyle _summaryNumberStyle =
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

  static const TextStyle _summaryTitleStyle =
      TextStyle(color: Colors.black54);

  // Hızlı işlemler kartı
  Widget buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
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
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String number;
  final String title;

  const _SummaryItem({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(number, style: _HomeScreenState._summaryNumberStyle),
        const SizedBox(height: 4),
        Text(title, style: _HomeScreenState._summaryTitleStyle),
      ],
    );
  }
}
