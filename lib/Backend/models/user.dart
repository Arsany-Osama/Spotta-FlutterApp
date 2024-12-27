class UserModel {
  final String name; // The name of the user
  final String role; // client or owner

  //  UserModel class --> 'name' and 'role'
  UserModel({required this.name, required this.role});

  // Convert UserModel to Map for Firebase
  // Map contains {key-value} pairs
  //for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name, // Map the 'name' field to the name property
      'role': role, // Map the 'role' field to the role property
    };
  }

  // Convert Map to UserModel
  // extracts values of 'name' and 'role' from Map
  // for fetching data from Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      role: map['role'],
    );
  }
}
