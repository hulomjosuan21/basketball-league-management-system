class ApiResponse<T> {
  final bool status;
  final String message;
  final T? payload;

  ApiResponse({required this.status, required this.message, this.payload});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      payload: json['payload'] != null ? fromJsonT(json['payload']) : null,
    );
  }

  factory ApiResponse.fromJsonNoPayload(Map<String, dynamic> json) {
    return ApiResponse<T>(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      payload: null,
    );
  }
}
