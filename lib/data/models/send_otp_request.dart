class SendOtpRequest {
  final String phone;
  final String countryCode;
  final int userType;
  final String name;
  final String address;
  final String email;
  final String pincode;
  final String stateId;
  final String districtId;
  final String cityId;
  final String? accessToken;
  // <== Add this

  SendOtpRequest({
    required this.phone,
    this.countryCode = '+91',
    required this.userType,
    this.name = '',
    this.address = '',
    this.email = '',
    this.pincode = '',
    this.stateId = '',
    this.districtId = '',
    this.cityId = '',
    this.accessToken,
     // <== Also here
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'country_code': countryCode,
    'user_type': userType,
    'name': name,
    'address': address,
    'email': email,
    'pincode': pincode,
    'state_id': stateId,
    'district_id': districtId,
    'city_id': cityId,
    'access_token': accessToken,
    // <== included in the request body
  };
}
