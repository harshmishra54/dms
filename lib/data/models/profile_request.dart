import 'dart:io';

class ProfileRequest {
  final String phone;
  final String name;
  final String firmName;
  final String address1;
  final String? address2;
  final String pincode;
  final int stateId;
  final int districtId;
  final int? cityId;
  final String? cityName;
  final String panNo;
  final String? dob;
  final String? doa;
  final String? profileImage;
  final String? email;
  final String? uniqueName;
  final String? gst;
  final String? licenseexpiry;
  final String? licenseNo;
  final String? refferalNo;
  final File? profileImageFile;

  ProfileRequest({
    required this.phone,
    required this.name,
    required this.firmName,
    required this.address1,
    this.address2,
    required this.pincode,
    required this.stateId,
    required this.districtId,
    this.cityId,
    this.cityName,
    required this.panNo,
    this.dob,
    this.doa,
    this.profileImage,
    this.email,
    this.uniqueName,
    this.gst,
    this.licenseexpiry,
    this.licenseNo,
    this.refferalNo,
    this.profileImageFile,


  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'name': name,
    'firmName': firmName,
    'address1': address1,
    'address2': address2,
    'pincode': pincode,
    'stateId': stateId,
    'districtId': districtId,
    'cityId': cityId,
    'cityName': cityName,
    'pan_no': panNo,
    'dob': dob,
    'doa': doa,
    'profileImage': profileImage,
    'email': email,
    'unique_name': uniqueName,
    'gst_no':gst,
    'licence_expiry':licenseexpiry,
    'license_no': licenseNo,
    'refferal_no':refferalNo,
  };
}
