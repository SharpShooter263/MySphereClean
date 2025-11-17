import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  final TextEditingController _linkController = TextEditingController();

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

  /// Firestore’da tuttuğumuz link modeli
  List<Map<String, String>> _links = [];

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _loadLinks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic>? linksFromDb = data["links"] as List<dynamic>?;

    if (linksFromDb != null) {
      setState(() {
        _links = linksFromDb
            .map((e) => {
                  "platform": e["platform"]?.toString() ?? "",
                  "url": e["url"]?.toString() ?? "",
                })
            .toList();
      });
    }
  }

  Future<void> _saveLinksToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set(
      {
        "links": _links,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _addLink() async {
    final rawUrl = _linkController.text.trim();

    if (rawUrl.isEmpty) {
      _showMessage("Lütfen bir link gir.");
      return;
    }

    String url = rawUrl;
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      url = "https://$url";
    }

    // Aynı link zaten kayıtlı mı?
    final alreadyExists = _links.any(
      (item) => item["platform"] == _selectedPlatform && item["url"] == url,
    );

    if (alreadyExists) {
      _showMessage("Bu link zaten kayıtlı.");
      return;
    }

    setState(() => _isSaving = true);

    _links.add({
      "platform": _selectedPlatform,
      "url": url,
    });

    await _saveLinksToFirestore();

    setState(() {
      _isSaving = false;
      _linkController.clear();
    });

    _showMessage("Link kaydedildi.");
  }

  Future<void> _deleteLink(int index) async {
    setState(() {
      _links.removeAt(index);
    });
    await _saveLinksToFirestore();
    _showMessage("Link silindi.");
  }

  Future<void> _editLink(int index) async {
    final current = _links[index];

    final TextEditingController editController =
        TextEditingController(text: current["url"] ?? "");

    String platform = current["platform"] ?? "Instagram";

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Linki Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: platform,
                items: _platforms
                    .map((p) =>
                        DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    platform = value;
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Platform",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editController,
                decoration: const InputDecoration(
                  labelText: "Link (https://...)",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Vazgeç"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Kaydet"),
              onPressed: () async {
                String newUrl = editController.text.trim();
                if (newUrl.isEmpty) {
                  _showMessage("Link boş olamaz.");
                  return;
                }
                if (!newUrl.startsWith("http://") &&
                    !newUrl.startsWith("https://")) {
                  newUrl = "https://$newUrl";
                }

                setState(() {
                  _links[index] = {
                    "platform": platform,
                    "url": newUrl,
                  };
                });

                await _saveLinksToFirestore();
                if (context.mounted) Navigator.pop(context);
                _showMessage("Link güncellendi.");
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      _showMessage("Bu link açılamadı.");
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sosyal medya veya web siteni ekle",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Platform seçimi
            DropdownButtonFormField<String>(
              value: _selectedPlatform,
              items: _platforms
                  .map((p) =>
                      DropdownMenuItem<String>(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPlatform = value;
                  });
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Link alanı
            TextField(
              controller: _linkController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: "Link (https://...)",
                prefixIcon: const Icon(Icons.link),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
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

            const SizedBox(height: 28),

            const Text(
              "Kayıtlı Linkler",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (_links.isEmpty)
              const Text(
                "Henüz link eklemedin.",
                style: TextStyle(color: Colors.black54),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _links.length,
                itemBuilder: (context, index) {
                  final item = _links[index];
                  final platform = item["platform"] ?? "";
                  final url = item["url"] ?? "";

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _openUrl(url),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    platform,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    url,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editLink(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteLink(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
