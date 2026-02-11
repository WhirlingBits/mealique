class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  /// A computed property to get the user's full name, with fallbacks.
  String get fullName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    }
    // Fallback to email if no name parts are available
    return email;
  }

  // Factory constructor to create a UserProfile from JSON data
  // Made safer to handle potentially null or missing values from the API.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}
