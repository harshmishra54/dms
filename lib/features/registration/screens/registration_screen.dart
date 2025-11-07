import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/customer_details_response.dart';
import 'package:TrustTags_DMS/data/models/profile_request.dart';
import 'package:TrustTags_DMS/data/repositories/location_repostitory.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/widgets/app_status_bar.dart';
import '../../home/presentation/home_navigation.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';


class RegistrationScreen extends StatefulWidget {
  final String phoneNumber;

  const RegistrationScreen({super.key, required this.phoneNumber});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
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
  bool isPincodeValid = false;



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

      // 1. Get IDs from pincode API
      final data = await repo.getCityStateByPincode(token, pincode);
      print("Pincode API response: $data");

      final fetchedStateId = data["state_id"];
      final fetchedDistrictId = data["district_id"];

      // 2. Fetch all states and find the matching state
      final allStates = await repo.fetchStates(token);
      final stateObj = allStates.cast<Map<String, dynamic>?>().firstWhere(
            (s) => s?['id'] == fetchedStateId,
        orElse: () => null,
      );

      final fetchedStateName = stateObj != null ? stateObj['name'] : "";

      // 3. Fetch districts for this state and find the matching district
      final fetchedDistricts = await repo.fetchDistricts(token, fetchedStateId);
      Map<String, dynamic>? districtObj;
      try {
        districtObj = fetchedDistricts.firstWhere((d) => d['id'] == fetchedDistrictId);
      } catch (_) {
        districtObj = null;
      }

      final fetchedDistrictName = districtObj != null ? districtObj['name'] : "";

      // 4. Update the UI state
      setState(() {
        states = allStates;           // make sure dropdown has all states
        districts = fetchedDistricts; // update dropdown list

        stateId = fetchedStateId;
        districtId = fetchedDistrictId;
        cityId = data["city_id"];
        stateName = fetchedStateName;
        districtName = fetchedDistrictName;

        stateController.text = stateName ?? "";
        districtController.text = districtName ?? "";
        isPincodeValid = true;
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

      nameController.text = data.name;
      firmController.text = data.firmName ?? '';
      address1Controller.text = data.address ?? '';
      pinController.text = data.pinCode?.toString() ?? '';
      phoneController.text = data.phone??"";
      stateId = data.stateId;
      cityId = data.cityId;

      // FIX: don’t set districtId to null from wrong field
      districtId = data.cityDistrictId; // update your model accordingly
    });

    // Always fetch if district is missing
    if (data.pinCode != null && data.pinCode.toString().length == 6) {
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
                    'Please enter correct details. Brand may use these to communicate with you and verify your account.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  buildLabel('Name'),
                  buildTextField(nameController),

                  buildLabel('Mobile Number'),
                  TextField(
                    controller: TextEditingController(text: widget.phoneNumber),
                    enabled: false,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration().copyWith(
                      fillColor: Colors.grey.shade100, // Same as other fields
                    ),
                  ),

                  buildLabel('Firm Name'),
                  buildTextField(firmController),

                  buildLabel('Address'),
                  buildTextField(address1Controller),

                  buildLabel('PIN Code'),
                  TextField(
                    controller: pinController,
                    maxLength: 6,
                    readOnly: isPincodeValid, // ✅ prevents editing but keeps appearance
                    enableInteractiveSelection: !isPincodeValid,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration().copyWith(
                      counterText: '', // 👈 hides the digit counter
                    ),
                    onChanged: (value) {
                      if (value.length == 6) {
                        _fetchLocationFromPincode(value);
                      }
                    },
                  ),

                  // State Field
                  // State dropdown
                  // State dropdown
                  // State dropdown
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
                    onChanged: isPincodeValid ? null : (value) async {   // ✅ disable if pin is valid
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

// District dropdown
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
                    onChanged: isPincodeValid ? null : (value) {   // ✅ disable if pin is valid
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
                          print('TOKEN USED FOR UPDATE PROFILE: $token');

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
                              MaterialPageRoute(builder: (context) => const HomeNavigation()),
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
                      )),
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
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
