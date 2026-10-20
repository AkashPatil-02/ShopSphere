class Profile {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? image;

  const Profile({
    required this.id,
    required this.image,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int?,
      image: json['image'] as String?,
      email: json['email'] as String?,
      firstName: json["firstName"] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
    );
  }
}
