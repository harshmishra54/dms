class ScanPostData {
  final bool isQrCodeDetected;
  final String uniqueCode;
  final String? innerCode;

  ScanPostData({
    required this.isQrCodeDetected,
    required this.uniqueCode,
    this.innerCode
  });

  Map<String, dynamic> toJson() {
    return {
      'isQrCodeDetected': isQrCodeDetected,
      'uniqueCode': uniqueCode,
      'innerCode': innerCode,
    };
  }
}
