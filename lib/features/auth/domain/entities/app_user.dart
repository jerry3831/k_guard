class AppUser {
  final String id;
  final String fullName;
  final String email;
  final DateTime createdAt;
  final String? avatarUrl;
  final bool isGuest;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.createdAt,
    this.avatarUrl,
    this.isGuest = false,
  });

  factory AppUser.guest() {
    return AppUser(
      id: 'guest_id',
      fullName: 'Guest',
      email: 'guest@currencyguard.app',
      createdAt: DateTime.now(),
      isGuest: true,
    );
  }

  String get firstName => fullName.split(' ').first;

  AppUser copyWith({
    String? id,
    String? fullName,
    String? email,
    DateTime? createdAt,
    String? avatarUrl,
    bool? isGuest,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
