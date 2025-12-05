class GetMyRewardRequest {
  final String rewardId;
  final String roleId;
  final String userId;

  GetMyRewardRequest({
    required this.rewardId,
    required this.roleId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      "reward_id": rewardId,
      "role_id": roleId,
      "user_id": userId,
    };
  }
}

// ================== RESPONSE MODEL ==================

class GetMyRewardResponse {
  final String? success;
  final String? message;
  final RewardData? data;

  GetMyRewardResponse({
    this.success,
    this.message,
    this.data,
  });

  factory GetMyRewardResponse.fromJson(Map<String, dynamic> json) {
    return GetMyRewardResponse(
      success: json["success"]?.toString(),
      message: json["message"]?.toString(),
      data: json["data"] != null ? RewardData.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class RewardData {
  final String? id;
  final String? randomId;
  final String? rewardId;
  final String? consumerId;
  final String? createdBy;
  final int? isVerified;
  final String? customerName;
  final List<String>? address;
  final String? pinCode;
  final String? phone;
  final int? cityId;
  final int? stateId;
  final String? email;
  final String? voucherImage;
  final int? points;
  final bool? isLuckydrawReward;
  final int? roleId;
  final String? updatedAt;
  final String? createdAt;
  final String? brandId;
  final String? verifyBy;
  final String? verifyComments;
  final String? updatedBy;
  final String? partnerName;
  final String? transactionId;
  final String? isDelivered;
  final String? schemeId;

  RewardData({
    this.id,
    this.randomId,
    this.rewardId,
    this.consumerId,
    this.createdBy,
    this.isVerified,
    this.customerName,
    this.address,
    this.pinCode,
    this.phone,
    this.cityId,
    this.stateId,
    this.email,
    this.voucherImage,
    this.points,
    this.isLuckydrawReward,
    this.roleId,
    this.updatedAt,
    this.createdAt,
    this.brandId,
    this.verifyBy,
    this.verifyComments,
    this.updatedBy,
    this.partnerName,
    this.transactionId,
    this.isDelivered,
    this.schemeId,
  });

  factory RewardData.fromJson(Map<String, dynamic> json) {
    return RewardData(
      id: json["id"],
      randomId: json["random_id"],
      rewardId: json["reward_id"],
      consumerId: json["consumer_id"],
      createdBy: json["created_by"],
      isVerified: json["is_verified"],
      customerName: json["customer_name"],
      address: json["address"] != null ? List<String>.from(json["address"]) : [],
      pinCode: json["pin_code"],
      phone: json["phone"],
      cityId: json["city_id"],
      stateId: json["state_id"],
      email: json["email"],
      voucherImage: json["voucher_image"],
      points: json["points"],
      isLuckydrawReward: json["is_luckydraw_reward"],
      roleId: json["role_id"],
      updatedAt: json["updatedAt"],
      createdAt: json["createdAt"],
      brandId: json["brand_id"],
      verifyBy: json["verify_by"],
      verifyComments: json["verify_comments"],
      updatedBy: json["updated_by"],
      partnerName: json["partner_name"],
      transactionId: json["transaction_id"],
      isDelivered: json["is_delivered"]?.toString(),
      schemeId: json["scheme_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "random_id": randomId,
      "reward_id": rewardId,
      "consumer_id": consumerId,
      "created_by": createdBy,
      "is_verified": isVerified,
      "customer_name": customerName,
      "address": address,
      "pin_code": pinCode,
      "phone": phone,
      "city_id": cityId,
      "state_id": stateId,
      "email": email,
      "voucher_image": voucherImage,
      "points": points,
      "is_luckydraw_reward": isLuckydrawReward,
      "role_id": roleId,
      "updatedAt": updatedAt,
      "createdAt": createdAt,
      "brand_id": brandId,
      "verify_by": verifyBy,
      "verify_comments": verifyComments,
      "updated_by": updatedBy,
      "partner_name": partnerName,
      "transaction_id": transactionId,
      "is_delivered": isDelivered,
      "scheme_id": schemeId,
    };
  }
}
