import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/get_child_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';


/// STATE = AsyncValue<List<ChildUser>>
final getChildsProvider =
StateNotifierProvider<GetChildsNotifier, AsyncValue<List<ChildUser>>>(
      (ref) => GetChildsNotifier(),
);

class GetChildsNotifier extends StateNotifier<AsyncValue<List<ChildUser>>> {
  GetChildsNotifier() : super(const AsyncValue.loading());

  final DioClient _dioClient = DioClient();

  Future<void> fetchChilds({required String id}) async {
    try {
      state = const AsyncValue.loading();

      final Response response = await _dioClient.post(
        ApiEndpoints.getchildrens,
        data: {
          "id": id,
        },
      );

      final parsed = GetChildsResponse.fromJson(response.data);

      state = AsyncValue.data(parsed.data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Optional: clear data when role/user changes
  void clear() {
    state = const AsyncValue.data([]);
  }
}
