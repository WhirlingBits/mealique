class HouseholdPermissions {
  final String userId;
  final bool canManageHousehold;
  final bool canManage;
  final bool canInvite;
  final bool canOrganize;

  HouseholdPermissions({
    required this.userId,
    required this.canManageHousehold,
    required this.canManage,
    required this.canInvite,
    required this.canOrganize,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'canManageHousehold': canManageHousehold,
      'canManage': canManage,
      'canInvite': canInvite,
      'canOrganize': canOrganize,
    };
  }
}
