import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  final TextEditingController _urlController = TextEditingController();

  final List<String> _platforms = [
    "Instagram",
    "YouTube",
    "TikTok",
    "X (Twitter)",
    "Facebook",
    "WhatsApp",
    "Web Sitesi",
    "Diğer",
  ];

  String _selectedPlatform = "Instagram";
  bool _isSaving = false;

  // Mevcut linkler: [{platform: ..., url: ...}, ...]
  List<Map<String, dynamic>> _links = [];

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data == null) return;

    final rawLinks = (data["links"] ?? []) as List<dynamic>;

    setState(() {
      _links = rawLinks
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    });
  }

  Future<void> _saveLinksToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({
      "links": _links,
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _addLink() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showMessage("Lütfen bir link girin.");
      return;
    }

    setState(() => _isSaving = true);

    _links.add({
      "platform": _selectedPlatform,
      "url": url,
    });

    await _saveLinksToFirestore();

    _urlController.clear();
    setState(() => _isSaving = false);

    _showMessage("Link eklendi.");
  }

  Future<void> _deleteLink(int index) async {
    setState(() => _isSaving = true);

    _links.removeAt(index);
    await _saveLinksToFirestore();

    setState(() => _isSaving = false);
    _showMessage("Link silindi.");
  }

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
          "Linklerim",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sosyal medya veya web siteni ekle",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Platform seçimi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPlatform,
                  items: _platforms
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedPlatform = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Link alanı
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "Link (https://...)",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _addLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4ECF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        "Link Ekle",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Kayıtlı Linkler",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _links.isEmpty
                  ? const Center(
                      child: Text(
                        "Henüz link eklemedin.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _links.length,
                      itemBuilder: (context, index) {
                        final link = _links[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: ListTile(
                            title: Text(link["platform"] ?? ""),
                            subtitle: Text(
                              link["url"] ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: _isSaving
                                  ? null
                                  : () => _deleteLink(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
