// route_meeting_list_model.dart

class RouteMeetingResponse {
  final int success;
  final String message;
  final List<RouteMeetingData> data;

  RouteMeetingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RouteMeetingResponse.fromJson(Map<String, dynamic> json) {
    return RouteMeetingResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<RouteMeetingData>.from(
          json['data'].map((x) => RouteMeetingData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class RouteMeetingData {
  final String id;
  final String tsiId;
  final String? routeId;
  final String uId;
  final String routeName;
  final String meetingName;
  final DateTime meetingTime;
  final List<String> meetingPhotos;
  final List<MeetingMember> meetingMembers;
  final String mobileNo;
  final String notes;
  final String action;
  final String? productDiscussed;
  final String? schemesDiscussed;
  final String? documentPdf;
  final double? expenseVenueCost;
  final double? expenseMaterialCost;
  final double? expenseTravelCost;
  final String? cropFocus;
  final String? location;
  final bool? isStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int memberCount;

  RouteMeetingData({
    required this.id,
    required this.tsiId,
    this.routeId,
    required this.uId,
    required this.routeName,
    required this.meetingName,
    required this.meetingTime,
    required this.meetingPhotos,
    required this.meetingMembers,
    required this.mobileNo,
    required this.notes,
    required this.action,
    this.productDiscussed,
    this.schemesDiscussed,
    this.documentPdf,
    this.expenseVenueCost,
    this.expenseMaterialCost,
    this.expenseTravelCost,
    this.cropFocus,
    this.location,
    this.isStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.memberCount,
  });

  factory RouteMeetingData.fromJson(Map<String, dynamic> json) {
    return RouteMeetingData(
      id: json['id'],
      tsiId: json['tsi_id'],
      routeId: json['route_id'],
      uId: json['u_id'],
      routeName: json['route_name'],
      meetingName: json['meeting_name'],
      meetingTime: DateTime.parse(json['meeting_time']),
      meetingPhotos: json['meeting_photos'] != null
          ? List<String>.from(json['meeting_photos'])
          : [],
      meetingMembers: json['meeting_members'] != null
          ? List<MeetingMember>.from(
          json['meeting_members'].map((x) => MeetingMember.fromJson(x)))
          : [],
      mobileNo: json['mobile_no'] ?? '',
      notes: json['notes'] ?? '',
      action: json['action'] ?? '',
      productDiscussed: json['product_discussed'],
      schemesDiscussed: json['schemes_discussed'],
      documentPdf: json['document_pdf'],
      expenseVenueCost: json['expense_venue_cost'] != null
          ? (json['expense_venue_cost'] as num).toDouble()
          : null,
      expenseMaterialCost: json['expense_material_cost'] != null
          ? (json['expense_material_cost'] as num).toDouble()
          : null,
      expenseTravelCost: json['expense_travel_cost'] != null
          ? (json['expense_travel_cost'] as num).toDouble()
          : null,
      cropFocus: json['crop_focus'],
      location: json['location'],
      isStatus: json['isStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      memberCount: json['member_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tsi_id': tsiId,
      'route_id': routeId,
      'u_id': uId,
      'route_name': routeName,
      'meeting_name': meetingName,
      'meeting_time': meetingTime.toIso8601String(),
      'meeting_photos': meetingPhotos,
      'meeting_members': meetingMembers.map((x) => x.toJson()).toList(),
      'mobile_no': mobileNo,
      'notes': notes,
      'action': action,
      'product_discussed': productDiscussed,
      'schemes_discussed': schemesDiscussed,
      'document_pdf': documentPdf,
      'expense_venue_cost': expenseVenueCost,
      'expense_material_cost': expenseMaterialCost,
      'expense_travel_cost': expenseTravelCost,
      'crop_focus': cropFocus,
      'location': location,
      'isStatus': isStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'member_count': memberCount,
    };
  }
}

class MeetingMember {
  final String name;
  final String phone;

  MeetingMember({
    required this.name,
    required this.phone,
  });

  factory MeetingMember.fromJson(Map<String, dynamic> json) {
    return MeetingMember(
      name: json['name'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}
