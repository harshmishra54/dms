class SchemeData {
  final String? productName;
  final String? uniqueCode;

  SchemeData({
    this.productName,
    this.uniqueCode,
  });

  factory SchemeData.fromJson(Map<String, dynamic> json) {
    return SchemeData(
      productName: json['productName'],
      uniqueCode: json['uniqueCode'],
    );
  }
}
