class QRShareScreen extends StatelessWidget {
  final String profileUrl;

  const QRShareScreen({super.key, required this.profileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Paylaş")),
      body: Center(
        child: QrImageView(
          data: profileUrl,
          size: 220,
        ),
      ),
    );
  }
}
