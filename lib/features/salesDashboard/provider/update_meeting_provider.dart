import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/meeting_update_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final updateMeetingStatusProvider =
StateNotifierProvider<UpdateMeetingStatusNotifier,
    AsyncValue<UpdateMeetingStatusResponse?>>((ref) {
  final dioClient = DioClient(); // direct use, no extra provider
  return UpdateMeetingStatusNotifier(dioClient);
});

class UpdateMeetingStatusNotifier
    extends StateNotifier<AsyncValue<UpdateMeetingStatusResponse?>> {
  final DioClient _dioClient;

  UpdateMeetingStatusNotifier(this._dioClient)
      : super(const AsyncValue.data(null));

  Future<void> updateMeetingStatus(
      UpdateMeetingStatusRequest request) async {
    state = const AsyncValue.loading();

    try {
      final Response response = await _dioClient.post(
        ApiEndpoints.updatemeetingstatus,
        data: request.toJson(),
      );

      final parsedResponse =
      UpdateMeetingStatusResponse.fromJson(response.data);

      state = AsyncValue.data(parsedResponse);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
