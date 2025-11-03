class TopStory {
  final String? assetUrl;
  final int? type; // 0 image, 1 video
  final String? caption;
  final String? thumbnailUrl;
  final String? redirectionUrl;

  TopStory({
    this.assetUrl,
    this.type,
    this.caption,
    this.thumbnailUrl,
    this.redirectionUrl,
  });

  factory TopStory.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TopStory(); // ✅ prevent crash
    return TopStory(
      assetUrl: json['assetUrl'] ?? json['asset_url'] ?? '',
      type: json['type'],
      caption: json['caption'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnail_url'] ?? '',
      redirectionUrl: json['redirectionUrl'] ?? json['redirection_url'] ?? '',
    );
  }
}

class DashboardData {
  final List<TopStory> topStories;
  final List<TopStory> slider;
  final List<TopStory> discover;

  DashboardData({
    required this.topStories,
    required this.slider,
    required this.discover,
  });

  factory DashboardData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardData(topStories: [], slider: [], discover: []); // ✅ safe default
    }

    List<TopStory> parseList(dynamic list) {
      if (list is List) {
        return list.map((e) => TopStory.fromJson(e as Map<String, dynamic>?)).toList();
      }
      return [];
    }

    return DashboardData(
      topStories: parseList(json['topStories']),
      slider: parseList(json['slider']),
      discover: parseList(json['discover']),
    );
  }
}

class DashboardResponse {
  final String success;
  final String message;
  final DashboardData data;

  DashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardResponse(
        success: "false",
        message: "Empty response",
        data: DashboardData(topStories: [], slider: [], discover: []),
      );
    }

    return DashboardResponse(
      success: json['success']?.toString() ?? '',
      message: json['message'] ?? '',
      data: DashboardData.fromJson(json['data']),
    );
  }
}
