import 'package:TrustTags_DMS/core/permissions/feature_access.dart';
import 'package:TrustTags_DMS/core/permissions/feature_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/permissions_model.dart';
import 'permissions_repository.dart';
import 'permissions_state.dart';
import 'dart:convert';

/* ------------------------------
   Dio Provider
--------------------------------*/
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/* ------------------------------
   Repository Provider
--------------------------------*/
final permissionsRepositoryProvider =
Provider<PermissionsRepository>((ref) {
  final dio = ref.read(dioClientProvider);
  return PermissionsRepository(dio);
});

/* ------------------------------
   StateNotifier Provider
--------------------------------*/
final permissionsProvider =
StateNotifierProvider<PermissionsNotifier, PermissionsState>((ref) {
  final repo = ref.read(permissionsRepositoryProvider);
  return PermissionsNotifier(repo);
});

/* ------------------------------
   Notifier
--------------------------------*/
class PermissionsNotifier extends StateNotifier<PermissionsState> {
  final PermissionsRepository _repository;

  PermissionsNotifier(this._repository)
      : super(const PermissionsState());

  /// 🔐 Load permissions using values from SharedPrefs
  Future<void> loadPermissions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final roleId = await SharedPrefsHelper.getRoleId();
      final userId = await SharedPrefsHelper.getUserId();

      if (roleId == null || userId == null) {
        throw Exception("Role ID or User ID missing");
      }

      final request = PermissionsRequestModel(
        roleId: roleId,
        id: userId,
      );

      final response = await _repository.fetchPermissions(request);

      // ✅ SAVE FULL RESPONSE TO SHARED PREFS
      await SharedPrefsHelper.savePermissions(
        response.toJson(), // 그대로
      );


      state = state.copyWith(
        isLoading: false,
        data: response,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  Future<void> hydrateFromCache() async {
    final json = await SharedPrefsHelper.getPermissions();
    if (json == null) return;

    try {
      final model = PermissionsResponseModel.fromJson(json);
      state = state.copyWith(data: model);
    } catch (_) {
      // ignore corrupted cache
    }
  }



  /// 🔐 Permission checker

  bool hasPermission(
      FeatureAccess feature, {
        bool view = false,
        bool create = false,
        bool approve = false,
      }
      ) {
    final permissions = state.data?.data;
    if (permissions == null) return false;

    final featurePermission = permissions.firstWhere(
          (f) => FeatureMapper.fromId(f.featureId) == feature,
      orElse: () => PermissionFeature(
        featureId: 0,
        featureName: '',
        permissions: FeaturePermissions(
          view: false,
          create: false,
          approve: false,
        ),
      ),
    );

    if (view) return featurePermission.permissions.view;
    if (create) return featurePermission.permissions.create;
    if (approve) return featurePermission.permissions.approve;

    return false;
  }

}
