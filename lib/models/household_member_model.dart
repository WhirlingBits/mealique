class HouseholdMember {
  final bool admin;
  final String email;
  final String fullName;
  final String group;
  final String household;
  final String username;

  HouseholdMember({
    required this.admin,
    required this.email,
    required this.fullName,
    required this.group,
    required this.household,
    required this.username,
  });

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      admin: json['admin'] == 'true' || json['admin'] == true,
      email: json['email'],
      fullName: json['fullName'],
      group: json['group'],
      household: json['household'],
      username: json['username'],
    );
  }
}

class HouseholdMemberResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<HouseholdMember> items;
  final String? next;
  final String? previous;

  HouseholdMemberResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.items,
    this.next,
    this.previous,
  });

  factory HouseholdMemberResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<HouseholdMember> members = itemsList.map((i) => HouseholdMember.fromJson(i)).toList();

    return HouseholdMemberResponse(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      items: members,
      next: json['next'],
      previous: json['previous'],
    );
  }
}
