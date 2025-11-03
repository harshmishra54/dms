/// Meeting Member (maps to PersonEntry in Kotlin/Backend)
class PersonEntry {
  final String name;
  final String phone;
  final String designation;

  PersonEntry({
    required this.name,
    required this.phone,
    required this.designation
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "designation": designation,
  };

  factory PersonEntry.fromJson(Map<String, dynamic> json) => PersonEntry(
    name: json["name"] ?? "",
    phone: json["phone"] ?? "",
    designation: json["designation"] ?? "",
  );
}

/// Request Model (Route Meeting API)
class RouteMeetingRequest {
  final int? routeId;
  final String? tsiId;
  final String? meetingName;
  final String? meetingType;
  final String location;
  final String? cropFocus;
  final String? mobileNumber;
  final String? routeName;
  final DateTime meetingDate;
  final List<PersonEntry>? meetingMembers;
  final List<String> eventPhotos;

  // Optional fields
  final String? eventNotes;
  final String? eventAction;
  final String? productDiscussed;
  final String? schemesDiscussed;
  final String? documentPdf;
  final String? expenseVenueCost;
  final String? expenseMaterialCost;
  final String? expenseTravelCost;
  final int? duration;

  RouteMeetingRequest({
    this.routeId,
    required this.tsiId,
    required this.meetingName,
    required this.meetingType,
    required this.location,
    required this.cropFocus,
    required this.mobileNumber,
    this.routeName,
    required this.meetingDate,
    this.meetingMembers,
    required this.eventPhotos,
    this.eventNotes,
    this.eventAction,
    this.productDiscussed,
    this.schemesDiscussed,
    this.documentPdf,
    this.expenseVenueCost,
    this.expenseMaterialCost,
    this.expenseTravelCost,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      "route_id": routeId ?? "",
      "tsi_id": tsiId,
      "meeting_name": meetingName,
      "meeting_type": meetingType,
      "location": location,
      "crop_focus": cropFocus,
      "mobile_number": mobileNumber,
      "route_name": routeName,
      "meeting_date": meetingDate.toIso8601String(),
      "meeting_members": meetingMembers != null
          ? meetingMembers!.map((m) => m.toJson()).toList()
          : [],
      "event_photos": eventPhotos,
      "event_notes": eventNotes ?? "",
      "event_action": eventAction ?? "",
      "product_discussed": productDiscussed ?? "",
      "schemes_discussed": schemesDiscussed ?? "",
      "document_pdf": documentPdf ?? "",
      "expense_venue_cost": expenseVenueCost ?? "",
      "expense_material_cost": expenseMaterialCost ?? "",
      "expense_travel_cost": expenseTravelCost ?? "",
      "duration": duration ?? "",
    };
  }

}

/// Response Model
class RouteMeetingResponse {
  final int success;
  final String message;
  final String? meetinId;
  final String? meetingName;
  final String? organiserName;

  RouteMeetingResponse({
    required this.success,
    required this.message,
    this.meetinId,
    this.meetingName,
    this.organiserName,

  });

  factory RouteMeetingResponse.fromJson(Map<String, dynamic> json) =>
      RouteMeetingResponse(
        success: json["success"] ?? 0,
        message: json["message"] ?? "",
        meetinId: json["meeting_id"] ?? "",
        meetingName: json["meet_name"] ?? "",
        organiserName: json["org_name"] ?? "",

      );
}
