class ChannelPerformanceResponse {
  final String? success;
  final String? message;
  final ChannelPerformanceData? data;

  ChannelPerformanceResponse({
    this.success,
    this.message,
    this.data,
  });

  factory ChannelPerformanceResponse.fromJson(Map<String, dynamic> json) {
    return ChannelPerformanceResponse(
      success: json['success']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] != null
          ? ChannelPerformanceData.fromJson(json['data'])
          : null,
    );
  }
}

class ChannelPerformanceData {
  final Reward? rewards;
  final int? counts;
  final List<Offer>? offers;
  final List<SchemeBanner>? schemeBanners;

  ChannelPerformanceData({
    this.rewards,
    this.counts,
    this.offers,
    this.schemeBanners,
  });

  factory ChannelPerformanceData.fromJson(Map<String, dynamic> json) {
    return ChannelPerformanceData(
      rewards: json['rewards'] != null
          ? Reward.fromJson(json['rewards'])
          : null,
      counts: int.tryParse(json['counts'].toString()) ?? 0,
      offers: (json['offers'] as List<dynamic>?)
          ?.map((e) => Offer.fromJson(e))
          .toList() ??
          [],
      schemeBanners: (json['schemesBanners'] as List<dynamic>?)
          ?.map((e) => SchemeBanner.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class Reward {
  final int? points;
  final int? availablePoints;
  final int? bonusPoints;
  final String? recordUid;
  final int? roleId;
  final bool? isUpdatedProfile;

  Reward({
    this.points,
    this.availablePoints,
    this.bonusPoints,
    this.recordUid,
    this.roleId,
    this.isUpdatedProfile,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      points: int.tryParse(json['points'].toString()) ?? 0,
      availablePoints: int.tryParse(json['available_points'].toString()) ?? 0,
      bonusPoints: int.tryParse(json['bonus_points'].toString()) ?? 0,
      recordUid: json['record_uid']?.toString(),
      roleId: int.tryParse(json['role_id'].toString()),
      isUpdatedProfile: json['is_updated_profile'] == true,
    );
  }
}

class SchemeBanner {
  final String? id; // Changed to String because IDs may be UUID or int
  final String? mainImage;
  final bool? isDeleted;
  final String? redirectionUrl;
  final String? schemeId;
  final String? caption;
  final String? thumbnailUrl;
  final int? activity;
  final String? createdAt;
  final String? updatedAt;

  SchemeBanner({
    this.id,
    this.mainImage,
    this.isDeleted,
    this.redirectionUrl,
    this.schemeId,
    this.caption,
    this.thumbnailUrl,
    this.activity,
    this.createdAt,
    this.updatedAt,
  });

  factory SchemeBanner.fromJson(Map<String, dynamic> json) {
    return SchemeBanner(
      id: json['id']?.toString(),
      mainImage: json['main_image']?.toString(),
      isDeleted: json['is_deleted'] == true,
      redirectionUrl: json['redirection_url']?.toString(),
      schemeId: json['scheme_id']?.toString(),
      caption: json['caption']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      activity: int.tryParse(json['activity']?.toString() ?? ''),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

class Offer {
  final String? id;
  final String? name;
  final String? endDate;
  final String? schemeImage;
  final int? type;
  final String? startDate;

  Offer({
    this.id,
    this.name,
    this.endDate,
    this.schemeImage,
    this.type,
    this.startDate,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      schemeImage: json['scheme_image']?.toString() ?? '',
      type: int.tryParse(json['type'].toString()) ?? 0,
      startDate: json['start_date']?.toString() ?? '',
    );
  }
}
