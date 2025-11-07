import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/customer_details_response.dart';
import 'package:TrustTags_DMS/data/models/profile_request.dart';
import 'package:TrustTags_DMS/data/repositories/location_repostitory.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:TrustTags_DMS/features/farmer/dashboard/farmer_dashboard_homenavigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';

class FarmerRegistration extends StatefulWidget {
  final String phoneNumber;

  const FarmerRegistration({super.key, required this.phoneNumber});

  @override
  State<FarmerRegistration> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<FarmerRegistration> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController firmController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController doaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController uniqueNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();

  // Auto fetched values
  int? stateId;
  int? districtId;
  int? cityId;
  String? stateName;
  String? districtName;
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> districts = [];

  bool isExistingUser = false; // <-- Flag to lock fields

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.phoneNumber;
    _loadStates();
    _fetchUserDetails();
  }

  Future<void> _loadStates() async {
    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null) return;

    final repo = LocationRepository(dioClient: DioClient());
    final fetchedStates = await repo.fetchStates(token);

    setState(() {
      states = fetchedStates;
    });
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
        districtObj = fetchedDistricts.firstWhere((d) => d['id'] == fetchedDistrictId);
      } catch (_) {
        districtObj = null;
      }
      final fetchedDistrictName = districtObj != null ? districtObj['name'] : "";

      setState(() {
        states = allStates;
        districts = fetchedDistricts;

        stateId = fetchedStateId;
        districtId = fetchedDistrictId;
        cityId = data["city_id"];
        stateName = fetchedStateName;
        districtName = fetchedDistrictName;

        stateController.text = stateName ?? "";
        districtController.text = districtName ?? "";
      });
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText("Error: $e")),
      );
    }
  }

  Future<void> _fetchUserDetails() async {
    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null) return;

    final provider = context.read<ProfileProvider>();
    await provider.fetchCustomerDetails(token);

    if (provider.decryptedCustomerData != null) {
      _populateUserFields(provider.decryptedCustomerData!);
    }
  }

  void _populateUserFields(CustomerData data) {
    setState(() {
      // Phone should always be non-editable
      phoneController.text = data.phone ?? widget.phoneNumber;

      // Only lock fields that already have valid values
      nameController.text = data.name ?? '';
      firmController.text = data.firmName ?? '';
      address1Controller.text = data.address ?? '';
      pinController.text = data.pinCode?.toString() ?? '';
      panController.text = data.panNo ?? '';
      uniqueNameController.text = data.uniqueName ?? '';

      stateId = data.stateId;
      cityId = data.cityId;
      districtId = data.cityDistrictId;


      // Set isExistingUser only if **all critical fields are filled**
      isExistingUser = (data.name != null &&
          data.address != null &&
          data.pinCode != null &&
          data.stateId != null &&
          data.cityDistrictId != null);
    });

    // If PIN code exists but state/district are missing, fetch them
    if (data.pinCode != null &&
        data.pinCode.toString().length == 6 &&
        (stateId == null || districtId == null)) {
      _fetchLocationFromPincode(data.pinCode.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: AutoTranslateText(
                      'Registration Form',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const AutoTranslateText(
                    'Welcome!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const AutoTranslateText(
                    'Please enter correct details',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  buildLabel('Name'),
                  buildTextField(nameController),

                  buildLabel('Mobile Number'),
                  TextField(
                    controller: TextEditingController(text: widget.phoneNumber),
                    enabled: false, // Always disabled
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration().copyWith(
                      fillColor: Colors.grey.shade100,
                    ),
                  ),

                  buildLabel('Address'),
                  buildTextField(address1Controller),

                  buildLabel('PIN Code'),
                  TextField(
                    controller: pinController,
                    readOnly: isExistingUser,
                    enableInteractiveSelection: !isExistingUser,
                    showCursor: !isExistingUser, // lock if existing user
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration().copyWith(counterText: ''),
                    onChanged: (value) {
                      if (value.length == 6 && !isExistingUser) {
                        _fetchLocationFromPincode(value);
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
                        child: AutoTranslateText(s['name'], overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: isExistingUser
                        ? null
                        : (value) async {
                      if (value == null) return;
                      setState(() {
                        stateId = value;
                        districtId = null;
                        districts = [];
                      });
                      final token = await SharedPrefsHelper.getAccessToken();
                      final repo = LocationRepository(dioClient: DioClient());
                      final fetchedDistricts = await repo.fetchDistricts(token!, value);
                      setState(() {
                        districts = fetchedDistricts;
                      });
                    },
                  ),

                  buildLabel('District'),
                  DropdownButtonFormField<int>(
                    value: districtId,
                    decoration: _inputDecoration(),
                    isExpanded: true,
                    items: districts.map((d) {
                      return DropdownMenuItem<int>(
                        value: d['id'],
                        child: AutoTranslateText(d['name'], overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: isExistingUser
                        ? null
                        : (value) {
                      setState(() {
                        districtId = value;
                      });
                    },
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final token = await SharedPrefsHelper.getAccessToken();
                        if (token == null || token.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: AutoTranslateText("User token not found")),
                          );
                          return;
                        }

                        if (stateId == null || districtId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: AutoTranslateText("Enter a valid pincode to auto-fill state/district")),
                          );
                          return;
                        }

                        final request = ProfileRequest(
                          phone: phoneController.text,
                          name: nameController.text,
                          firmName: firmController.text,
                          address1: address1Controller.text,
                          address2: address2Controller.text,
                          pincode: pinController.text,
                          stateId: stateId!,
                          districtId: districtId!,
                          cityId: cityId,
                          cityName: null,
                          panNo: panController.text,
                          dob: dobController.text,
                          doa: doaController.text,
                          profileImage: "",
                          email: emailController.text,
                          uniqueName: uniqueNameController.text,
                        );

                        await Provider.of<ProfileProvider>(context, listen: false)
                            .updateProfile(token, request);

                        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

                        if (profileProvider.errorMessage == null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const FarmerDashboardHomenavigation()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: AutoTranslateText("Failed to update profile: ${profileProvider.errorMessage}")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const AutoTranslateText(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 16),
      child: AutoTranslateText(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      readOnly: isExistingUser,
      enableInteractiveSelection: !isExistingUser, // 👈 important
      showCursor: !isExistingUser,  // lock if existing user
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(
        color: !isExistingUser ? Colors.black : Colors.grey.shade700,
      ),
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
