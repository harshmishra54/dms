import 'package:TrustTags_DMS/data/models/permissions_model.dart';

class PermissionsState {
  final bool isLoading;
  final PermissionsResponseModel? data;
  final String? error;

  const PermissionsState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  PermissionsState copyWith({
    bool? isLoading,
    PermissionsResponseModel? data,
    String? error,
  }) {
    return PermissionsState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}
