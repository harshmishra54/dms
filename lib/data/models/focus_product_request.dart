class FocusProductRequest {
  final String locationId;
  final String type; // changed from int to String
  final bool isDistributor;

  FocusProductRequest({required this.type, required this.locationId, required this.isDistributor});

  Map<String, dynamic> toJson() {
    return {
      "locationId": locationId,
      "type": type, // already a string
      "isDistributor":isDistributor,
    };
  }
}
