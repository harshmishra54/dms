class ScanPostData {
  final bool isQrCodeDetected;
  final String uniqueCode;
  final String? innerCode;
  final int? packagingtype;

  ScanPostData({
    required this.isQrCodeDetected,
    required this.uniqueCode,
    this.innerCode,
    this.packagingtype,
  });

  Map<String, dynamic> toJson() {
    return {
      'isQrCodeDetected': isQrCodeDetected,
      'uniqueCode': uniqueCode,
      'innerCode': innerCode,
      'packaging_type': packagingtype,
    };
  }
}
