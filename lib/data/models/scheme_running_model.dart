import 'dart:convert';

/// Top level parser
RewardResponse rewardResponseFromJson(String str) =>
    RewardResponse.fromJson(json.decode(str));

String rewardResponseToJson(RewardResponse data) =>
    json.encode(data.toJson());

class RewardResponse {
  final bool success;
  final List<RewardData> data;

  RewardResponse({
    required this.success,
    required this.data,
  });

  factory RewardResponse.fromJson(Map<String, dynamic> json) => RewardResponse(
    success: json["success"] ?? false,
    data: json["data"] == null
        ? []
        : List<RewardData>.from(
        json["data"].map((x) => RewardData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class RewardData {
  final String id;
  final String rewardId;
  final String name;
  final int points;
  final int stock;
  final String image;
  final int userType;
  final int redeemedStock;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final int? bonusPoints;
  final bool isWalletBased;
  final bool isLuckydrawReward;

  RewardData({
    required this.id,
    required this.rewardId,
    required this.name,
    required this.points,
    required this.stock,
    required this.image,
    required this.userType,
    required this.redeemedStock,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.bonusPoints,
    required this.isWalletBased,
    required this.isLuckydrawReward,
  });

  factory RewardData.fromJson(Map<String, dynamic> json) => RewardData(
    id: json["id"] ?? "",
    rewardId: json["reward_id"] ?? "",
    name: json["name"] ?? "",
    points: json["points"] ?? 0,
    stock: json["stock"] ?? 0,
    image: json["image"] ?? "",
    userType: json["user_type"] ?? 0,
    redeemedStock: json["redeemed_stock"] ?? 0,
    createdAt: json["createdAt"] ?? "",
    updatedAt: json["updatedAt"] ?? "",
    isDeleted: json["is_deleted"] ?? false,
    bonusPoints: json["bonus_points"],
    isWalletBased: json["is_wallet_based"] ?? false,
    isLuckydrawReward: json["is_luckydraw_reward"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "reward_id": rewardId,
    "name": name,
    "points": points,
    "stock": stock,
    "image": image,
    "user_type": userType,
    "redeemed_stock": redeemedStock,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "is_deleted": isDeleted,
    "bonus_points": bonusPoints,
    "is_wallet_based": isWalletBased,
    "is_luckydraw_reward": isLuckydrawReward,
  };
}

class RewardRequest {
  final int? roleId;

  RewardRequest({this.roleId});

  Map<String, dynamic> toJson() => {
    "role_id": roleId,
  };
}
