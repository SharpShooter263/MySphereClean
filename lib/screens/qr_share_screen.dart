import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QRShareScreen extends StatelessWidget {
  final String profileUrl;

  const QRShareScreen({super.key, required this.profileUrl});

  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
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
            // KART ARKA PLANI ARTIK TEMA UYUMLU
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: QrImageView(
                data: profileUrl,
                size: 220,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Bu QR kodu okutarak MySphere profilini açabilirler.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),

      // PAYLAŞ BUTONU
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () {
          Share.share(
            profileUrl,
            subject: "MySphere profilim",
          );
        },
        label: const Text("Linki Paylaş"),
        icon: const Icon(Icons.share),
      ),
    );
  }
}
