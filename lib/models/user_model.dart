class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;
  final String? profileImage;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'profile_image': profileImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      role: map['role'],
      profileImage: map['profile_image'],
    );
  }
}
