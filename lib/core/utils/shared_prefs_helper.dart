import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _accessTokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _phoneKey = 'phone';
  static const String _roleIdKey = 'role_id';
  static const String _userNameKey = 'user_name';
  static const String _firmNameKey = 'firm_name';
  static const String _emailKey = 'email';

  static const String _pointsKey = 'points';
  static const String _availablePointsKey = 'available_points';
  static const String _blockedPointsKey = 'blocked_points';
  static const String _utilizePointsKey = 'utilize_points';
  static const String _bonusPointsKey = 'bonus_points';

  static const String _isBlockedKey = 'is_blocked';
  static const String _isUpdatedProfileKey = 'is_updated_profile';
  static const String _isUpdatedVersionKey = 'is_updated_version';

  // ---- ROUTE INFO ----
  static const String _routeIdKey = 'selected_route_id';
  static const String _routeNameKey = 'selected_route_name';
  static const String _dailyRouteIdKey = 'daily_route_id';  // NEW
  static const String _locationIdKey='daily_location_id';
  static const String _meetingCompletedKey = 'meeting_completed';
  static const String _dailyLocationIdKey = 'location_id';
  static const String _dailyRoleIdKey = 'daily_role_id';



  /// Save OTP verified user data
  /// Save OTP verified user data
  static Future<void> saveOtpUserData(Map<String, dynamic> json, {int? selectedRoleId}) async {
    final prefs = await SharedPreferences.getInstance();

    // Safe helper to parse int
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    await prefs.setString(_accessTokenKey, json['jwt_token'] ?? '');
    await prefs.setString(_userIdKey, json['id'] ?? '');
    await prefs.setString(_phoneKey, json['phone'] ?? '');

    // --- ROLE ID LOGIC ---
    int backendRoleId = parseInt(json['role_id']);
    if (selectedRoleId == 18) {
      // If widget.selectedRoleId == 18 → save backend roleId
      await prefs.setInt(_roleIdKey, backendRoleId);
    } else {
      // Otherwise save widget.selectedRoleId
      await prefs.setInt(_roleIdKey, selectedRoleId ?? backendRoleId);
    }

    await prefs.setString(_userNameKey, json['name'] ?? '');
    await prefs.setString(_firmNameKey, json['firm_name'] ?? '');
    await prefs.setString(_emailKey, json['email'] ?? '');

    // Use safe parsing for all numeric fields
    await prefs.setInt(_pointsKey, parseInt(json['points']));
    await prefs.setInt(_availablePointsKey, parseInt(json['available_points']));
    await prefs.setInt(_blockedPointsKey, parseInt(json['blocked_points']));
    await prefs.setInt(_utilizePointsKey, parseInt(json['utilize_points']));
    await prefs.setInt(_bonusPointsKey, parseInt(json['bonus_points']));

    await prefs.setBool(_isBlockedKey, json['is_blocked'] ?? false);
    await prefs.setBool(_isUpdatedProfileKey, json['is_updated_profile'] ?? false);
    await prefs.setBool(_isUpdatedVersionKey, json['is_updated_version'] ?? false);
  }


  // --- ROUTE SAVE/GET ---
  static Future<void> saveSelectedRoute(String routeId, String routeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_routeIdKey, routeId);
    await prefs.setString(_routeNameKey, routeName);
  }

  static Future<String?> getSelectedRouteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_routeIdKey);
  }

  static Future<String?> getSelectedRouteName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_routeNameKey);
  }

  static Future<void> clearSelectedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_routeIdKey);
    await prefs.remove(_routeNameKey);
  }

  /// Getters
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  static Future<int?> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_roleIdKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<int?> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveDailyRouteId(String dailyRouteId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyRouteIdKey, dailyRouteId);
  }
  static Future<String?> getDailyRouteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dailyRouteIdKey);
  }
  static Future<void> saveDailyLocationId(String locationId) async{
    final prefs= await SharedPreferences.getInstance();
    await prefs.setString(_locationIdKey,locationId);
  }
  static Future<String?> getDailylocationId() async{
    final prefs= await SharedPreferences.getInstance();
    return prefs.getString(_locationIdKey);
  }
  static Future<void> setMeetingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_meetingCompletedKey, value);
  }

  static Future<bool> getMeetingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_meetingCompletedKey) ?? false;
  }
  static Future<void> setDailylocationIdKey(String locationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyLocationIdKey, locationId);
  }
  static Future<String?> getDailylocationIdKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dailyLocationIdKey);
  }
  static Future<void> saveDailyRoleId(String roleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyRoleIdKey, roleId);
  }
  static Future<String?> getDailyRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dailyRoleIdKey);
  }

}
