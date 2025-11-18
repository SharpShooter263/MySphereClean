import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _aboutController = TextEditingController();

  String? _photoUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      _emailController.text = user.email ?? '';

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      _nameController.text =
          data?['name'] ?? user.displayName ?? '';
      _aboutController.text = data?['about'] ?? '';
      _photoUrl = data?['photoUrl'];

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Kullanıcı verisi yüklenemedi: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil bilgileri yüklenemedi')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() => _isUploadingPhoto = true);

      final user = FirebaseAuth.instance.currentUser!;
      final file = File(picked.path);

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'photoUrl': url,
        },
        SetOptions(merge: true),
      );

      setState(() {
        _photoUrl = url;
        _isUploadingPhoto = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf yüklendi')),
      );
    } catch (e, st) {
      debugPrint('Fotoğraf yüklenemedi: $e\n$st');
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf yüklenemedi: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    try {
      setState(() => _isSaving = true);

      final user = FirebaseAuth.instance.currentUser!;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name': _nameController.text.trim(),
          'about': _aboutController.text.trim(),
          'photoUrl': _photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      setState(() => _isSaving = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil kaydedildi')),
      );
    } catch (e) {
      debugPrint('Profil kaydedilemedi: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil kaydedilemedi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF000000);
    final cardColor = const Color(0xFF1E1E1E);
    final purple = const Color(0xFF7C4DFF);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text('Profilim'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              'Bilgilerini düzenle',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isUploadingPhoto ? null : _pickAndUploadImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF3A3A3A),
                    backgroundImage:
                        _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                    child: _photoUrl == null
                        ? const Text(
                            'Ç',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: purple,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (_isUploadingPhoto)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Ad Soyad',
              controller: _nameController,
              icon: Icons.person,
              cardColor: cardColor,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'E-posta',
              controller: _emailController,
              icon: Icons.email,
              readOnly: true,
              cardColor: cardColor,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Hakkımda (isteğe bağlı)',
              controller: _aboutController,
              icon: Icons.info,
              maxLines: 3,
              cardColor: cardColor,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Kaydet',
                        style: TextStyle(
                          color: Colors.white,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color cardColor,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  maxLines: maxLines,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
