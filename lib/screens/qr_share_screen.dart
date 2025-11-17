import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QRShareScreen extends StatelessWidget {
  final String profileUrl;

  const QRShareScreen({super.key, required this.profileUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.colorScheme.onBackground,
        ),
        title: Text(
          "QR Paylaş",
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR’i açık renk bir kartın içine aldık + arka planını beyaz yaptık
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141414) // koyu gri kart
                    : Colors.white,           // açık tema için beyaz kart
                borderRadius: BorderRadius.circular(24),
              ),
              child: QrImageView(
                data: profileUrl,
                size: 220,
                backgroundColor: Colors.white, // QR arkası her zaman beyaz
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Bu QR kodu okutarak MySphere profilini açabilirler.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6A4ECF),
        foregroundColor: Colors.white,
        onPressed: () {
          Share.share(
            profileUrl,
            subject: "MySphere profilim",
          );
        },
        label: const Text("Linki Paylaş"),
      ),
    );
  }
}
