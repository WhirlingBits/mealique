class HouseholdInvitation {
  final String token;
  final int usesLeft;
  final String groupId;
  final String householdId;

  HouseholdInvitation({
    required this.token,
    required this.usesLeft,
    required this.groupId,
    required this.householdId,
  });

  factory HouseholdInvitation.fromJson(Map<String, dynamic> json) {
    return HouseholdInvitation(
      token: json['token'],
      usesLeft: json['usesLeft'] ?? 0,
      groupId: json['groupId'],
      householdId: json['householdId'],
    );
  }
}
