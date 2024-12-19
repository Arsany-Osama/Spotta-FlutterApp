class UserModel {
  final String name;
  final String role; // client or owner

  UserModel({required this.name, required this.role});

  // Convert UserModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
    };
  }

  // Convert Map to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      role: map['role'],
    );
  }
}
