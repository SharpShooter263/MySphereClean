import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicProfileScreen extends StatelessWidget {
  /// Görüntülenecek kullanıcının UID'si
  final String userId;

  const PublicProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onBackground),
        title: Text(
          'Profil',
          style: TextStyle(
            color: colors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Profil bulunamadı.',
                style: TextStyle(color: colors.onBackground),
              ),
            );
          }

          final data = snapshot.data!.data()!;
          final name = (data['name'] ?? '') as String;
          final bio = (data['bio'] ?? '') as String;
          final photoUrl = data['photoUrl'] as String?;
          final email = (data['email'] ?? '') as String? ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profil fotoğrafı / harf avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colors.primaryContainer.withOpacity(0.9),
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? Text(
                          (name.isNotEmpty
                                  ? name[0]
                                  : (email.isNotEmpty ? email[0] : '?'))
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: colors.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),

                const SizedBox(height: 16),

                // İsim
                Text(
                  name.isNotEmpty ? name : 'İsimsiz kullanıcı',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Bio
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackground.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                // Şimdilik dummy kutu – ileride sosyal linkler gelecek
                Card(
                  color: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Sosyal bağlantılar yakında burada görünecek.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
