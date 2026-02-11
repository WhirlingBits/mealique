class UserSelf {
  final bool admin;
  final String email;
  final String fullName;
  final String group;
  final String household;
  final String username;

  UserSelf({
    required this.admin,
    required this.email,
    required this.fullName,
    required this.group,
    required this.household,
    required this.username,
  });

  factory UserSelf.fromJson(Map<String, dynamic> json) {
    bool adminValue = false;
    if (json['admin'] is bool) {
      adminValue = json['admin'];
    } else if (json['admin'] is String) {
      adminValue = json['admin'].toLowerCase() == 'true';
    }

    return UserSelf(
      admin: adminValue,
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      group: json['group'] ?? '',
      household: json['household'] ?? '',
      username: json['username'] ?? '',
    );
  }
}
