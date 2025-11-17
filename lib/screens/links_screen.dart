import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  final _linkController = TextEditingController();
  String _selectedPlatform = "Instagram";

  final List<String> platforms = [
    "Instagram",
    "YouTube",
    "TikTok",
    "X (Twitter)",
    "Facebook",
    "WhatsApp",
    "Web Sitesi",
    "Diğer"
  ];

  Future<void> _addLink() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String url = _linkController.text.trim();
    if (url.isEmpty) return;

    final docRef =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    await docRef.update({
      "links": FieldValue.arrayUnion([
        {"platform": _selectedPlatform, "url": url}
      ])
    });

    _linkController.clear();
    setState(() {});
  }

  Future<void> _deleteLink(Map<String, dynamic> link) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    await docRef.update({
      "links": FieldValue.arrayRemove([link])
    });

    setState(() {});
  }

  Future<void> _editLink(Map<String, dynamic> link, String newUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    await docRef.update({
      "links": FieldValue.arrayRemove([link])
    });

    await docRef.update({
      "links": FieldValue.arrayUnion([
        {"platform": link["platform"], "url": newUrl}
      ])
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
          "Linklerim",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: user == null
          ? const Center(child: Text("Kullanıcı bulunamadı"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final links = List<Map<String, dynamic>>.from(
                    userData["links"] ?? []);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sosyal medya veya web siteni ekle",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      // Platform seçimi
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedPlatform,
                          underline: const SizedBox(),
                          isExpanded: true,
                          items: platforms
                              .map((platform) => DropdownMenuItem(
                                    value: platform,
                                    child: Text(platform),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedPlatform = value!);
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Link girme kutusu
                      TextField(
                        controller: _linkController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Link (https://...)",
                          prefixIcon:
                              const Icon(Icons.link, color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Link ekle butonu
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _addLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            "Link Ekle",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Kayıtlı Linkler",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      if (links.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "Henüz link eklemedin.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      else
                        Column(
                          children: links.map((link) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.link, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          link["platform"],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          link["url"],
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteLink(link),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
