import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class QrShareScreen extends StatefulWidget {
  const QrShareScreen({super.key});

  @override
  State<QrShareScreen> createState() => _QrShareScreenState();
}

class _QrShareScreenState extends State<QrShareScreen> {
  String? _profileUrl;

  static const String _baseProfileUrl = "https://mysphere.app/p/";

  @override
  void initState() {
    super.initState();
    _buildProfileUrl();
  }

  void _buildProfileUrl() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _profileUrl = null);
      return;
    }

    final uid = user.uid;
    setState(() {
      _profileUrl = "$_baseProfileUrl$uid";
    });
  }

  void _copyToClipboard() {
    if (_profileUrl == null) return;

    Clipboard.setData(ClipboardData(text: _profileUrl!));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil linki kopyalandı.")),
    );
  }

  void _shareProfile() {
    if (_profileUrl == null) return;

    Share.share(_profileUrl!, subject: "MySphere profilim");
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF6A4ECF);

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
          "QR Paylaş",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _profileUrl == null
          ? const Center(
              child: Text(
                "Oturum açmış bir kullanıcı bulunamadı.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    "Profilini QR ile paylaş",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Arkadaşların bu QR kodu okutarak\n"
                    "MySphere profilini görebilir.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 32),

                  // QR KOD KARTI
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: _profileUrl!,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Profil QR kodun",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // LİNK KUTUSU
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _profileUrl!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PAYLAŞ BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _shareProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(Icons.share),
                      label: const Text(
                        "Profil Linkini Paylaş",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
