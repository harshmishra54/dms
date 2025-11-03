import 'package:TrustTags_DMS/data/models/profile_request.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/customer_details_response.dart';
import 'package:TrustTags_DMS/data/repositories/location_repostitory.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController firmController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController uniqueNameController = TextEditingController();
  final TextEditingController licenseExpiryController = TextEditingController();
  final TextEditingController licenController = TextEditingController();

  // Location data
  int? stateId;
  int? districtId;
  int? cityId;
  String? stateName;
  String? districtName;
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> districts = [];
  int? _roleId;

  bool _isEditMode = false; // Track edit mode

  @override
  void initState() {
    super.initState();
    _loadStates();
    _loadRoleId();
    _fetchUserDetails();
  }

  @override
  void dispose() {
    nameController.dispose();
    firmController.dispose();
    address1Controller.dispose();
    pinController.dispose();
    panController.dispose();
    gstController.dispose();
    phoneController.dispose();
    uniqueNameController.dispose();
    licenseExpiryController.dispose();
    licenController.dispose();
    super.dispose();
  }

  Future<void> _loadRoleId() async {
    final roleId = await SharedPrefsHelper.getRoleId();
    setState(() {
      _roleId = roleId;
    });
  }

  bool _isNotEmpty(String? value) => value != null && value.trim().isNotEmpty;

  Future<void> _loadStates() async {
    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null) return;

    final repo = LocationRepository(dioClient: DioClient());
    final fetchedStates = await repo.fetchStates(token);
    if (!mounted) return;

    setState(() {
      states = fetchedStates;
    });
  }

  Future<void> _fetchUserDetails() async {
    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null) return;

    final provider = context.read<ProfileProvider>();
    await provider.fetchCustomerDetails(token);

    if (!mounted) return;
    if (provider.decryptedCustomerData != null) {
      _populateUserFields(provider.decryptedCustomerData!);
    }
  }

  void _populateUserFields(CustomerData data) {
    setState(() {
      nameController.text = data.name;
      firmController.text = data.firmName ?? '';
      address1Controller.text = data.address ?? '';
      pinController.text = data.pinCode?.toString() ?? '';
      phoneController.text = data.phone ?? "";
      gstController.text = data.gstNo ?? "";
      panController.text = data.panNo ?? "";
      uniqueNameController.text = data.uniqueName ?? "";
      licenController.text = data.licenceNo ?? "";
      stateId = data.stateId;
      cityId = data.cityId;
      districtId = data.cityDistrictId;

      if (data.licenseexpiry != null && data.licenseexpiry!.isNotEmpty) {
        DateTime parsedDate =
            DateTime.tryParse(data.licenseexpiry!) ?? DateTime.now();
        licenseExpiryController.text =
        "${parsedDate.day.toString().padLeft(2, '0')}-"
            "${parsedDate.month.toString().padLeft(2, '0')}-"
            "${parsedDate.year}";
      } else {
        licenseExpiryController.text = "";
      }
    });

    if (data.pinCode != null && data.pinCode.toString().length == 6) {
      _fetchLocationFromPincode(data.pinCode.toString());
    }
  }

  Future<void> _fetchLocationFromPincode(String pincode) async {
    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null || token.isEmpty) return;

    try {
      final repo = LocationRepository(dioClient: DioClient());
      final data = await repo.getCityStateByPincode(token, pincode);

      final fetchedStateId = data["state_id"];
      final fetchedDistrictId = data["district_id"];

      final allStates = await repo.fetchStates(token);
      final stateObj = allStates.cast<Map<String, dynamic>?>().firstWhere(
            (s) => s?['id'] == fetchedStateId,
        orElse: () => null,
      );

      final fetchedStateName = stateObj != null ? stateObj['name'] : "";

      final fetchedDistricts = await repo.fetchDistricts(token, fetchedStateId);
      Map<String, dynamic>? districtObj;
      try {
        districtObj =
            fetchedDistricts.firstWhere((d) => d['id'] == fetchedDistrictId);
      } catch (_) {
        districtObj = null;
      }

      final fetchedDistrictName = districtObj != null ? districtObj['name'] : "";

      if (!mounted) return;
      setState(() {
        states = allStates;
        districts = fetchedDistricts;
        stateId = fetchedStateId;
        districtId = fetchedDistrictId;
        cityId = data["city_id"];
        stateName = fetchedStateName;
        districtName = fetchedDistrictName;
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid or unsupported PIN code")),
      );
    }
  }

  bool get _hideFields => _roleId == 0 || _roleId == 18 || _roleId == 19 || _roleId==23;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.errorMessage != null) {
          return Scaffold(
            body: Center(child: Text(provider.errorMessage!)),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              const AppStatusBar(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'User Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditMode ? Icons.close : Icons.edit,
                        color: AppColors.primaryPurple,
                      ),
                      onPressed: () {
                        setState(() {
                          _isEditMode = !_isEditMode;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabel('Name'),
                      buildTextField(nameController, readOnly: true),

                      buildLabel('Mobile Number'),
                      buildTextField(phoneController, readOnly: true),

                      if (!_hideFields) ...[
                        buildLabel('Firm Name'),
                        buildTextField(firmController, readOnly: !_isEditMode),
                      ],

                      buildLabel('Address'),
                      buildTextField(address1Controller, readOnly: !_isEditMode),

                      buildLabel('PIN Code'),
                      TextFormField(
                        controller: pinController,
                        maxLength: 6,
                        readOnly: !_isEditMode,
                        enableInteractiveSelection: _isEditMode,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration().copyWith(counterText: ''),
                        onChanged: (value) async {
                          if (_isEditMode && value.length == 6) {
                            await _fetchLocationFromPincode(value);
                          }
                        },
                      ),

                      buildLabel('State'),
                      DropdownButtonFormField<int>(
                        value: stateId,
                        decoration: _inputDecoration(),
                        isExpanded: true,
                        items: states.map((s) {
                          return DropdownMenuItem<int>(
                            value: s['id'],
                            child: Text(s['name'], overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: _isEditMode
                            ? (value) async {
                          if (value == null) return;
                          setState(() {
                            stateId = value;
                            districtId = null;
                            districts = [];
                          });
                          final token = await SharedPrefsHelper.getAccessToken();
                          final repo = LocationRepository(dioClient: DioClient());
                          final fetchedDistricts = await repo.fetchDistricts(token!, value);
                          if (!mounted) return;
                          setState(() {
                            districts = fetchedDistricts;
                          });
                        }
                            : null,
                      ),

                      buildLabel('District'),
                      DropdownButtonFormField<int>(
                        value: districtId,
                        decoration: _inputDecoration(),
                        isExpanded: true,
                        items: districts.map((d) {
                          return DropdownMenuItem<int>(
                            value: d['id'],
                            child: Text(d['name'], overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: _isEditMode
                            ? (value) {
                          setState(() {
                            districtId = value;
                          });
                        }
                            : null,
                      ),

                      if (!_hideFields) ...[
                        buildLabel('GST Number'),
                        buildTextField(gstController, readOnly: !_isEditMode),

                        buildLabel('PAN Number'),
                        buildTextField(panController, readOnly: !_isEditMode),

                        // buildLabel('Unique Name'),
                        // buildTextField(uniqueNameController, readOnly:true),

                        buildLabel('License Expiry'),
                        TextFormField(
                          controller: licenseExpiryController,
                          readOnly: true,
                          onTap: _isEditMode ? () async {
                            DateTime initialDate = DateTime.now();
                            if (licenseExpiryController.text.isNotEmpty) {
                              // Try to parse existing date
                              final parts = licenseExpiryController.text.split('-');
                              if (parts.length == 3) {
                                final day = int.tryParse(parts[0]) ?? 1;
                                final month = int.tryParse(parts[1]) ?? 1;
                                final year = 2000 + (int.tryParse(parts[2]) ?? 0); // "23" -> 2023
                                initialDate = DateTime(year, month, day);
                              }
                            }

                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null && mounted) {
                              // Format as dd-MM-yy
                              licenseExpiryController.text =
                              "${picked.day.toString().padLeft(2, '0')}-"
                                  "${picked.month.toString().padLeft(2, '0')}-"
                                  "${picked.year.toString().substring(2)}"; // last 2 digits
                            }
                          } : null,
                          decoration: _inputDecoration(),
                        ),


                        buildLabel('License No'),
                        buildTextField(licenController, readOnly: !_isEditMode),
                      ],

                      if (_isEditMode) ...[
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final token = await SharedPrefsHelper.getAccessToken();
                              if (token == null || token.isEmpty) return;

                              // Build request
                              final request = ProfileRequest(
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                firmName: firmController.text.trim(),
                                address1: address1Controller.text.trim(),
                                pincode: pinController.text.trim(),
                                gst: gstController.text.trim(),
                                licenseNo: licenController.text.trim(),
                                uniqueName: uniqueNameController.text.trim(),
                                licenseexpiry: licenseExpiryController.text.trim(),
                                stateId: stateId?? 0,
                                cityId: cityId,
                                districtId: districtId??0,
                                panNo: panController.text.trim(),
                              );

                              try {
                                setState(() => _isEditMode = false); // disable edit while processing
                                await context.read<ProfileProvider>().updateProfile(token, request);

                                final provider = context.read<ProfileProvider>();
                                if (provider.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: ${provider.errorMessage}")),
                                  );
                                  setState(() => _isEditMode = true); // re-enable edit on error
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Profile Updated Successfully")),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                                setState(() => _isEditMode = true);
                              }
                            },
                            child: const Text(
                              "Update Profile",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 16),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller,
      {bool isNumber = false, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      readOnly: readOnly,
      enableInteractiveSelection: !readOnly, // ✅ prevents crash
      decoration: _inputDecoration(),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      filled: true,
      fillColor: Colors.grey.shade100,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
      ),
    );
  }
}
