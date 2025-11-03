class GeneralQueryRequest {
  final String query;

  GeneralQueryRequest({required this.query});

  Map<String, dynamic> toJson() {
    return {
      'query': query,
    };
  }
}
class GeneralQueryResponse {
  final String query;
  final String answer;

  GeneralQueryResponse({required this.query, required this.answer});

  factory GeneralQueryResponse.fromJson(Map<String, dynamic> json) {
    return GeneralQueryResponse(
      query: json['query'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}
