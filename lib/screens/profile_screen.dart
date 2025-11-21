import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isSaving = false;
  bool _isUploadingImage = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ImagePicker _picker = ImagePicker();
  String? _photoUrl;

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
        _photoUrl = data['photoUrl'] as String?;
        setState(() {});
      }
    } catch (_) {
      // İstersen buraya Snackbar ile hata mesajı koyabiliriz.
    }
  }

  Future<void> _pickAndUploadImage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        return; // kullanıcı iptal etti
      }

      setState(() {
        _isUploadingImage = true;
      });

      final file = File(pickedFile.path);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child('${user.uid}.jpg');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': downloadUrl,
      });

      if (!mounted) return;

      setState(() {
        _photoUrl = downloadUrl;
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil fotoğrafı güncellendi.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf yüklenirken bir hata oluştu.')),
      );
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        title: Text(
          'Profilim',
          style: TextStyle(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bilgilerini düzenle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 24),

            // Avatar + fotoğraf değiştirme
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickAndUploadImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor:
                              colorScheme.primaryContainer.withOpacity(0.9),
                          backgroundImage: _photoUrl != null
                              ? NetworkImage(_photoUrl!)
                              : null,
                          child: _photoUrl == null
                              ? Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text[0].toUpperCase()
                                      : (email.isNotEmpty
                                          ? email[0].toUpperCase()
                                          : '?'),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: colorScheme.primary,
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isUploadingImage)
                    Text(
                      'Fotoğraf yükleniyor...',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onBackground.withOpacity(0.7),
                      ),
                    )
                  else
                    Text(
                      'Fotoğrafı değiştir',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ad Soyad
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
                labelStyle:
                    TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                filled: true,
                fillColor: colorScheme.surface,
                prefixIcon: Icon(Icons.person, color: colorScheme.primary),
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
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'E-posta',
                hintText: email,
                labelStyle:
                    TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                filled: true,
                fillColor: colorScheme.surface,
                prefixIcon: Icon(Icons.email, color: colorScheme.primary),
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
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Hakkımda (isteğe bağlı)',
                alignLabelWithHint: true,
                labelStyle:
                    TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                filled: true,
                fillColor: colorScheme.surface,
                prefixIcon:
                    Icon(Icons.info_outline, color: colorScheme.primary),
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
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isSaving
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        'Kaydet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
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
