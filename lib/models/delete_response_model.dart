class DeleteResponse {
  final String message;
  final bool error;

  DeleteResponse({required this.message, required this.error});

  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResponse(
      message: json['message'] ?? '',
      error: json['error'] ?? false,
    );
  }
}
