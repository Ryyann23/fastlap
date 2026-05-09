import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../features/auth/data/auth_service.dart';

class UserHeaderAvatar extends StatelessWidget {
  const UserHeaderAvatar({
    super.key,
    required this.radius,
    this.lightBackgroundColor = const Color(0xFFFFA95B),
    this.darkBackgroundColor = const Color(0xFF8B4DDE),
  });

  final double radius;
  final Color lightBackgroundColor;
  final Color darkBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<LocalAuthUser?>(
      future: AuthService().getActiveUser(),
      builder: (context, snapshot) {
        final avatarBase64 = snapshot.data?.avatarBase64;
        final avatarUrl = snapshot.data?.avatarUrl;
        final avatarBytes = _avatarBytes(avatarBase64);
        final ImageProvider? avatarImage;
        if (avatarBytes != null) {
          avatarImage = MemoryImage(avatarBytes);
        } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
          avatarImage = NetworkImage(avatarUrl);
        } else {
          avatarImage = null;
        }

        return CircleAvatar(
          radius: radius,
          backgroundColor: isDark ? darkBackgroundColor : lightBackgroundColor,
          backgroundImage: avatarImage,
          child: avatarImage == null
              ? Icon(
                  Icons.person,
                  color: Colors.white,
                  size: radius * 1.2,
                )
              : null,
        );
      },
    );
  }

  Uint8List? _avatarBytes(String? base64Data) {
    if (base64Data == null || base64Data.isEmpty) return null;
    try {
      return base64Decode(base64Data);
    } catch (_) {
      return null;
    }
  }
}
