import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QRShareScreen extends StatelessWidget {
  final String profileUrl;

  const QRShareScreen({super.key, required this.profileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "QR Paylaş",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: profileUrl,
              size: 220,
            ),
            const SizedBox(height: 20),
            Text(
              "Bu QR kodu okutarak MySphere profilini açabilirler.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6A4ECF),
        onPressed: () {
          // Profil linkini paylaş
          Share.share(
            profileUrl,
            subject: "MySphere profilim",
          );
        },
        label: const Text(
          "Linki Paylaş",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.share),
      ),
    );
  }
}
