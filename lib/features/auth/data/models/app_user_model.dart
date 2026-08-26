import 'dart:convert';
import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  final String? sessionToken;
  final String? passwordHash; // ← only used during sign-in verification

  const AppUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.createdAt,
    super.avatarUrl,
    super.isGuest = false,
    this.sessionToken,
    this.passwordHash,
  });

  factory AppUserModel.guest() {
    return AppUserModel(
      id: 'guest_id',
      fullName: 'Guest',
      email: 'guest@currencyguard.app',
      createdAt: DateTime.now(),
      isGuest: true,
      sessionToken: null,
    );
  }

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      avatarUrl: json['avatar_url'] as String?,
      isGuest: false,
    );
  }

  factory AppUserModel.fromSQLiteRow(Map<String, dynamic> row) {
    return AppUserModel(
      id: row['id'] as String,
      fullName: row['full_name'] as String,
      email: row['email'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      passwordHash: row['password_hash'] as String?,
    );
  }

  factory AppUserModel.fromCacheMap(Map<String, dynamic> map) {
    return AppUserModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      avatarUrl: map['avatar_url'] as String?,
      isGuest: map['is_guest'] as bool? ?? false,
      sessionToken: map['token'] as String?,
    );
  }

  Map<String, dynamic> toCacheMap() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'created_at': createdAt.toIso8601String(),
        'is_guest': isGuest,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (sessionToken != null) 'token': sessionToken,
      };
}
