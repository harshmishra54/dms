import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/data/models/profile_request.dart';
import 'package:TrustTags_DMS/data/models/profile_response.dart';
import 'package:TrustTags_DMS/data/models/customer_details_response.dart';
import 'package:TrustTags_DMS/data/repositories/profile_repository.dart';
import 'package:TrustTags_DMS/core/utils/token_decryptor.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository repository;

  bool isLoading = false;
  String? errorMessage;

  ProfileUpdateResponse? response;

  // Raw encrypted API response
  CustomerDetailsResponse? customerDetails;

  // Decrypted customer data as a model
  CustomerData? decryptedCustomerData;

  ProfileProvider({required this.repository});

  // Update Profile API
  Future<void> updateProfile(String token, ProfileRequest request) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      response = await repository.updateProfile(token, request);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🧹 Helper to clean addresses
  String _cleanAddress(String? rawAddress) {
    if (rawAddress == null || rawAddress.isEmpty) return "";

    final parts = rawAddress.split('/');
    final validParts = parts
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty && p.toLowerCase() != "undefined" && p.toLowerCase() != "null")
        .toList();

    return validParts.join(" / ").trim();
  }


  // Fetch and decrypt customer details
  Future<void> fetchCustomerDetails(String token) async {
    isLoading = true;
    errorMessage = null;
    decryptedCustomerData = null; // reset old data
    customerDetails = null;
    notifyListeners();

    try {
      final result = await repository.getCustomerDetails(token);
      customerDetails = result;

      final encrypted = result.data;
      if (encrypted != null && encrypted.isNotEmpty) {
        final decryptedJson = TokenDecryptor.decrypt(encrypted);

        // 👇 Debug print full decrypted JSON
        print("🔑 Decrypted Customer JSON: $decryptedJson");

        final parsed = json.decode(decryptedJson) as Map<String, dynamic>;

        // 🧹 Clean the address field BEFORE parsing into model
        if (parsed["address"] != null) {
          parsed["address"] = _cleanAddress(parsed["address"]);
        }

        decryptedCustomerData = CustomerData.fromJson(parsed);
      }
    } catch (e) {
      errorMessage = e.toString();
      print("❌ Error in fetchCustomerDetails: $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
