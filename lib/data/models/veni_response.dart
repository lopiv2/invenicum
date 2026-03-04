class VeniResponse {
  final String answer;
  final String? action;
  final Map<String, dynamic>? data;

  VeniResponse({required this.answer, this.action, this.data});

  factory VeniResponse.fromJson(Map<String, dynamic> json) {
    return VeniResponse(
      answer: json['answer'] ?? '',
      action: json['action'],
      data: json['data'],
    );
  }
}