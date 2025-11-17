import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ayarlar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tercihlerini düzenle",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // 🔧 Şimdilik sadece örnek ayarlar, ileride Firebase'e bağlarız
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text("Bildirimler"),
              subtitle: const Text("Yeni bağlantı ve görüntüleme bildirimleri"),
            ),
            const Divider(),

            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text("Karanlık tema (yakında)"),
              subtitle: const Text("Şimdilik sadece taslak olarak duruyor"),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("Hakkında"),
              subtitle: const Text("MySphere profil yönetim uygulaması"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
