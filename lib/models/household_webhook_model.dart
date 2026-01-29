class HouseholdWebhook {
  final bool enabled;
  final String name;
  final String url;
  final String webhookType;
  final String? scheduledTime;
  final String groupId;
  final String householdId;
  final String id;

  HouseholdWebhook({
    required this.enabled,
    required this.name,
    required this.url,
    required this.webhookType,
    this.scheduledTime,
    required this.groupId,
    required this.householdId,
    required this.id,
  });

  factory HouseholdWebhook.fromJson(Map<String, dynamic> json) {
    return HouseholdWebhook(
      enabled: json['enabled'] ?? false,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      webhookType: json['webhookType'],
      scheduledTime: json['scheduledTime'],
      groupId: json['groupId'],
      householdId: json['householdId'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'name': name,
      'url': url,
      'webhookType': webhookType,
      'scheduledTime': scheduledTime,
    };
  }
}

class HouseholdWebhookResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<HouseholdWebhook> items;
  final String? next;
  final String? previous;

  HouseholdWebhookResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.items,
    this.next,
    this.previous,
  });

  factory HouseholdWebhookResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<HouseholdWebhook> webhooks = itemsList.map((i) => HouseholdWebhook.fromJson(i)).toList();

    return HouseholdWebhookResponse(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      items: webhooks,
      next: json['next'],
      previous: json['previous'],
    );
  }
}
