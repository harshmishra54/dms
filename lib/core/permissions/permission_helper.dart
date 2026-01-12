import 'package:TrustTags_DMS/data/models/permissions_model.dart';

import 'feature_access.dart';
import 'feature_mapper.dart';


class PermissionHelper {
  final PermissionsResponseModel permissions;

  PermissionHelper(this.permissions);

  PermissionFeature? _getFeature(FeatureAccess feature) {
    try {
      return permissions.data.firstWhere(
            (e) => FeatureMapper.fromId(e.featureId) == feature,
      );
    } catch (_) {
      return null;
    }
  }

  bool canView(FeatureAccess feature) {
    return _getFeature(feature)?.permissions.view ?? false;
  }

  bool canCreate(FeatureAccess feature) {
    return _getFeature(feature)?.permissions.create ?? false;
  }

  bool canApprove(FeatureAccess feature) {
    return _getFeature(feature)?.permissions.approve ?? false;
  }
}
