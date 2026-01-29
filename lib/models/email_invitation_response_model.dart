class EmailInvitationResponse {
  final bool success;
  final String? error;

  EmailInvitationResponse({required this.success, this.error});

  factory EmailInvitationResponse.fromJson(Map<String, dynamic> json) {
    return EmailInvitationResponse(
      success: json['success'] ?? false,
      error: json['error'],
    );
  }
}
