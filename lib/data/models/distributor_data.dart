class DistributorData {
  final String id;
  final String name;

  DistributorData({
    required this.id,
    required this.name,
  });

  factory DistributorData.fromJson(Map<String, dynamic> json) {
    return DistributorData(
      id: json["id"] ?? '',
      name: json["name"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }

  @override
  String toString() {
    return name;
  }
}
