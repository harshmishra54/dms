// user_reward_history_model.dart

// ================== REQUEST ===================
class UserRewardHistoryRequest {
  final String userId;

  UserRewardHistoryRequest({required this.userId});

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
    };
  }
}

// ================== RESPONSE ===================
class UserRewardHistoryResponse {
  final String? success;
  final List<UserRewardHistoryData>? data;

  UserRewardHistoryResponse({
    this.success,
    this.data,
  });

  factory UserRewardHistoryResponse.fromJson(Map<String, dynamic> json) {
    return UserRewardHistoryResponse(
      success: json['success']?.toString(),
      data: json['data'] != null
          ? List<UserRewardHistoryData>.from(
          json['data'].map((x) => UserRewardHistoryData.fromJson(x)))
          : null,
    );
  }
}

class UserRewardHistoryData {
  final String? id;
  final String? customerName;
  final String? consumerId;
  final List<String>? address;
  final String? phone;
  final String? createdAt;
  final String? email;
  final int? cityId;
  final int? stateId;
  final String? pinCode;
  final String? voucherImage; // ✅ NEW FIELD
  final Consumer? consumer;
  final Reward? reward;
  final StateData? state;
  final CityData? city;
  final LuckyDraw? luckyDraw;
  final int? isVerified;
  final String? partnerName;
  final String? verifyComment;
  final String? transactionId;

  UserRewardHistoryData({
    this.id,
    this.customerName,
    this.consumerId,
    this.address,
    this.phone,
    this.createdAt,
    this.email,
    this.cityId,
    this.stateId,
    this.pinCode,
    this.voucherImage, // ✅
    this.consumer,
    this.reward,
    this.state,
    this.city,
    this.luckyDraw,
    this.isVerified,
    this.partnerName,
    this.verifyComment,
    this.transactionId,
  });

  factory UserRewardHistoryData.fromJson(Map<String, dynamic> json) {
    return UserRewardHistoryData(
      id: json['id'],
      customerName: json['customer_name'],
      consumerId: json['consumer_id'],
      address: json['address'] != null
          ? List<String>.from(json['address'])
          : [],
      phone: json['phone'],
      createdAt: json['createdAt'],
      email: json['email'],
      cityId: json['city_id'],
      stateId: json['state_id'],
      pinCode: json['pin_code'],
      voucherImage: json['voucher_image'], // ✅
      consumer: json['consumer'] != null
          ? Consumer.fromJson(json['consumer'])
          : null,
      reward: json['reward'] != null ? Reward.fromJson(json['reward']) : null,
      state: json['state'] != null ? StateData.fromJson(json['state']) : null,
      city: json['city'] != null ? CityData.fromJson(json['city']) : null,
      luckyDraw: json['lucky_draw'] != null
          ? LuckyDraw.fromJson(json['lucky_draw'])
          : null,
      isVerified: json['is_verified']??"",
      partnerName: json['partner_name']??"",
      verifyComment: json['verify_comments']??"",
      transactionId: json['transaction_id']??"",
    );
  }
}

// ================== NESTED MODELS ===================

class Consumer {
  final String? id;
  final String? roleId;
  final String? name;
  final String? countryCode;
  final String? phone;
  final String? email;
  final String? dob;
  final String? gender;
  final String? pinCode;
  final int? cityId;
  final int? stateId;
  final String? address;
  final String? jwtToken;
  final String? fcmToken;
  final String? createdAt;
  final String? updatedAt;
  final int? points;
  final int? availablePoints;
  final int? blockedPoints;
  final int? utilizePoints;
  final int? bonusPoints;
  final String? recordUid;
  final bool? isDeleted;
  final bool? isUpdatedProfile;
  final bool? isBlocked;
  final bool? isUpdatedVersion;

  Consumer({
    this.id,
    this.roleId,
    this.name,
    this.countryCode,
    this.phone,
    this.email,
    this.dob,
    this.gender,
    this.pinCode,
    this.cityId,
    this.stateId,
    this.address,
    this.jwtToken,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.points,
    this.availablePoints,
    this.blockedPoints,
    this.utilizePoints,
    this.bonusPoints,
    this.recordUid,
    this.isDeleted,
    this.isUpdatedProfile,
    this.isBlocked,
    this.isUpdatedVersion,
  });

  factory Consumer.fromJson(Map<String, dynamic> json) {
    return Consumer(
      id: json['id'],
      roleId: json['role_id'],
      name: json['name'],
      countryCode: json['country_code'],
      phone: json['phone'],
      email: json['email'],
      dob: json['dob'],
      gender: json['gender'],
      pinCode: json['pin_code'],
      cityId: json['city_id'],
      stateId: json['state_id'],
      address: json['address'],
      jwtToken: json['jwt_token'],
      fcmToken: json['fcm_token'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      points: json['points'],
      availablePoints: json['available_points'],
      blockedPoints: json['blocked_points'],
      utilizePoints: json['utilize_points'],
      bonusPoints: json['bonus_points'],
      recordUid: json['record_uid'],
      isDeleted: json['is_deleted'],
      isUpdatedProfile: json['is_updated_profile'],
      isBlocked: json['is_blocked'],
      isUpdatedVersion: json['is_updated_version'],
    );
  }
}

class Reward {
  final String? id;
  final String? name;
  final bool? isWalletBased;

  Reward({
    this.id,
    this.name,
    this.isWalletBased,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      name: json['name'],
      isWalletBased: json['is_wallet_based'],
    );
  }
}

class StateData {
  final String? name;

  StateData({this.name});

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(
      name: json['name'],
    );
  }
}

class CityData {
  final String? name;

  CityData({this.name});

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      name: json['name'],
    );
  }
}

class LuckyDraw {
  final String? drawName;

  LuckyDraw({this.drawName});

  factory LuckyDraw.fromJson(Map<String, dynamic> json) {
    return LuckyDraw(
      drawName: json['draw_name'],
    );
  }
}
