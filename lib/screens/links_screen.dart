import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedPlatform = "Instagram";

  bool _isSaving = false;
  List<Map<String, dynamic>> _links = [];

  final List<String> _platforms = const [
    "Instagram",
    "YouTube",
    "TikTok",
    "X (Twitter)",
    "Facebook",
    "WhatsApp",
    "Web Sitesi",
    "Diğer",
  ];

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;
    final linksFromDb = (data["links"] ?? []) as List<dynamic>;

    setState(() {
      _links = linksFromDb
          .map((e) => {
                "platform": e["platform"] ?? "",
                "url": e["url"] ?? "",
              })
          .toList();
    });
  }

  Future<void> _saveLinksToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({"links": _links});
  }

  Future<void> _addLink() async {
    final rawUrl = _urlController.text.trim();
    if (rawUrl.isEmpty) return;

    String url = rawUrl;
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      url = "https://$url";
    }

    setState(() => _isSaving = true);

    _links.add({
      "platform": _selectedPlatform,
      "url": url,
    });

    await _saveLinksToFirestore();

    setState(() {
      _isSaving = false;
      _urlController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Link kaydedildi.")),
    );
  }

  Future<void> _deleteLink(int index) async {
    setState(() {
      _links.removeAt(index);
    });
    await _saveLinksToFirestore();
  }

  Future<void> _editLink(int index) async {
    final current = _links[index];

    _urlController.text = current["url"] ?? "";
    _selectedPlatform = current["platform"] ?? "Diğer";

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Linki Düzenle",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 16),
              _buildPlatformDropdown(),
              const SizedBox(height: 12),
              _buildUrlField(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final rawUrl = _urlController.text.trim();
                    if (rawUrl.isEmpty) return;

                    String url = rawUrl;
                    if (!url.startsWith("http://") &&
                        !url.startsWith("https://")) {
                      url = "https://$url";
                    }

                    setState(() {
                      _links[index] = {
                        "platform": _selectedPlatform,
                        "url": url,
                      };
                    });

                    await _saveLinksToFirestore();

                    if (mounted) Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Link güncellendi.")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Kaydet",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    _urlController.clear();
  }

  Future<void> _openLink(String url) async {
    if (url.isEmpty) return;

    Uri uri;
    try {
      uri = Uri.parse(url);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Geçersiz link formatı.")),
      );
      return;
    }

    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Link açılamadı.")),
      );
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Widget _buildPlatformDropdown() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.12),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPlatform,
          dropdownColor: theme.cardColor,
          iconEnabledColor: colorScheme.onBackground,
          style: TextStyle(
            color: colorScheme.onBackground,
          ),
          isExpanded: true,
          items: _platforms
              .map(
                (p) => DropdownMenuItem<String>(
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
    );
  }

  Widget _buildUrlField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: _urlController,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        labelText: "Link (https://...)",
        labelStyle: TextStyle(
          color: colorScheme.onBackground.withOpacity(0.7),
        ),
        filled: true,
        fillColor: theme.cardColor,
        prefixIcon: Icon(Icons.link, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(
        color: colorScheme.onBackground,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Linklerim",
          style: TextStyle(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sosyal medya veya web siteni ekle",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),

            // Platform seçimi
            _buildPlatformDropdown(),
            const SizedBox(height: 12),

            // URL input
            _buildUrlField(),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _addLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

            Text(
              "Kayıtlı Linkler",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _links.isEmpty
                  ? Center(
                      child: Text(
                        "Henüz link eklemedin.",
                        style: TextStyle(
                          color:
                              colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _links.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _links[index];
                        final platform = item["platform"] ?? "";
                        final url = item["url"] ?? "";

                        return InkWell(
                          onTap: () => _openLink(url),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor
                                      .withOpacity(0.12),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        platform,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onBackground,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        url,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colorScheme.onBackground
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: colorScheme.onBackground
                                        .withOpacity(0.8),
                                  ),
                                  onPressed: () => _editLink(index),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: colorScheme.error,
                                  ),
                                  onPressed: () => _deleteLink(index),
                                ),
                              ],
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
