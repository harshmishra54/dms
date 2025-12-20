import 'package:TrustTags_DMS/features/scan/models/scan_response.dart';

class AsyncScanResponse {
  final String uid;
  bool isProcessed;
  bool isValid;

  // Points reward
  int points;

  // Spinner reward
  bool isSpinner;
  String? spinnerId;
  List<Segment>? segments;

  String? error;

  AsyncScanResponse({
    required this.uid,
    this.isProcessed = false,
    this.isValid = false,
    this.points = 0,
    this.isSpinner = false,
    this.spinnerId,
    this.segments,
    this.error,
  });
}
