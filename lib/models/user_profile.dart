class UserProfile {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? address;
  final double? lastLat;
  final double? lastLng;
  final bool isAdmin;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.address,
    this.lastLat,
    this.lastLng,
    this.isAdmin = false,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        lastLat: (json['last_lat'] as num?)?.toDouble(),
        lastLng: (json['last_lng'] as num?)?.toDouble(),
        isAdmin: json['is_admin'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'phone': phone,
        'address': address,
        'last_lat': lastLat,
        'last_lng': lastLng,
      };

  String get displayName => name ?? email.split('@').first;
  String get initials => displayName.length > 1
      ? displayName.substring(0, 2).toUpperCase()
      : displayName.toUpperCase();

  UserProfile copyWith({
    String? name,
    String? phone,
    String? address,
    double? lastLat,
    double? lastLng,
  }) {
    return UserProfile(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      isAdmin: isAdmin,
      createdAt: createdAt,
    );
  }
}
