import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isSaving = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snap = await _firestore.collection('users').doc(user.uid).get();
      final data = snap.data();

      if (data != null) {
        _nameController.text = (data['name'] ?? '') as String;
        _bioController.text = (data['bio'] ?? '') as String;
      }
    } catch (_) {
      // Hata olursa sessiz geçiyoruz, istersen Snackbar ekleyebiliriz
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İsim boş olamaz.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'bio': bio,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi.')),
      );

      // Kaydettikten sonra bir önceki sayfaya dönebiliriz
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellenemedi.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Profilim',
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
              'Bilgilerini düzenle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Avatar
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFDDD3FF),
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text[0].toUpperCase()
                      : (email.isNotEmpty ? email[0].toUpperCase() : '?'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B3BC4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ad Soyad
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // E-posta (salt okunur)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'E-posta',
                hintText: email,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bio
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Hakkımda (isteğe bağlı)',
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.info_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Kaydet butonu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
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
                        'Kaydet',
                        style: TextStyle(
                          fontSize: 18,
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
