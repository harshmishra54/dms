// permissions_model.dart

/* ===========================
   REQUEST BODY MODEL
=========================== */

class PermissionsRequestModel {
  final int roleId;
  final String id;

  PermissionsRequestModel({
    required this.roleId,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      "role_id": roleId,
      "id": id,
    };
  }
}

/* ===========================
   RESPONSE MODEL
=========================== */

class PermissionsResponseModel {
  final bool success;
  final int count;
  final List<PermissionFeature> data;

  PermissionsResponseModel({
    required this.success,
    required this.count,
    required this.data,
  });

  factory PermissionsResponseModel.fromJson(Map<String, dynamic> json) {
    return PermissionsResponseModel(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: json['data'] != null
          ? List<PermissionFeature>.from(
        json['data'].map((x) => PermissionFeature.fromJson(x)),
      )
          : [],
    );
  }

  // ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

/* ===========================
   FEATURE MODEL
=========================== */

class PermissionFeature {
  final int featureId;
  final String featureName;
  final FeaturePermissions permissions;

  PermissionFeature({
    required this.featureId,
    required this.featureName,
    required this.permissions,
  });

  factory PermissionFeature.fromJson(Map<String, dynamic> json) {
    return PermissionFeature(
      featureId: json['feature_id'] ?? 0,
      featureName: json['feature_name'] ?? '',
      permissions: FeaturePermissions.fromJson(json['permissions'] ?? {}),
    );
  }

  // ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'feature_id': featureId,
      'feature_name': featureName,
      'permissions': permissions.toJson(),
    };
  }
}

/* ===========================
   PERMISSIONS MODEL
=========================== */

class FeaturePermissions {
  final bool view;
  final bool create;
  final bool approve;

  FeaturePermissions({
    required this.view,
    required this.create,
    required this.approve,
  });

  factory FeaturePermissions.fromJson(Map<String, dynamic> json) {
    return FeaturePermissions(
      view: json['view'] ?? false,
      create: json['create'] ?? false,
      approve: json['approve'] ?? false,
    );
  }

  // ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'view': view,
      'create': create,
      'approve': approve,
    };
  }
}
