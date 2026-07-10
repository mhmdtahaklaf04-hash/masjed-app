class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String role; // 'admin' or 'user'
  final DateTime createdAt;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.fcmToken,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      fcmToken: map['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }
}
