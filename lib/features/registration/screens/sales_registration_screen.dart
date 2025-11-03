import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/customer_details_response.dart';
import 'package:TrustTags_DMS/data/models/profile_request.dart';
import 'package:TrustTags_DMS/data/repositories/location_repostitory.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/sales_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';

class SalesRegistrationScreen extends StatefulWidget {
  final String phoneNumber;

  const SalesRegistrationScreen({super.key, required this.phoneNumber});

  @override
  State<SalesRegistrationScreen> createState() => _SalesRegistrationScreenState();
}

class _SalesRegistrationScreenState extends State<SalesRegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

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
    _fetchStates(); // load state list initially
    _fetchUserDetails();
  }

  Future<void> _fetchStates() async {
    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null) return;
    final repo = LocationRepository(dioClient: DioClient());
    final fetchedStates = await repo.fetchStates(token);
    setState(() {
      states = fetchedStates;
    });
  }

  Future<void> _fetchDistrictsForState(int stateId) async {
    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null) return;
    final repo = LocationRepository(dioClient: DioClient());
    final fetchedDistricts = await repo.fetchDistricts(token, stateId);
    setState(() {
      districts = fetchedDistricts;
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

      // find state name
      final fetchedStates = await repo.fetchStates(token);
      final stateObj = fetchedStates.firstWhere(
            (s) => s['id'] == fetchedStateId,
        orElse: () => <String, dynamic>{},
      );
      final fetchedStateName = stateObj['name'] ?? "";

      // find district name
      final fetchedDistricts = await repo.fetchDistricts(token, fetchedStateId);
      final districtObj = fetchedDistricts.firstWhere(
            (d) => d['id'] == fetchedDistrictId,
        orElse: () => <String, dynamic>{},
      );
      final fetchedDistrictName = districtObj['name'] ?? "";

      setState(() {
        states = fetchedStates;
        districts = fetchedDistricts;
        stateId = fetchedStateId;
        districtId = fetchedDistrictId;
        cityId = data["city_id"];
        stateName = fetchedStateName;
        districtName = fetchedDistrictName;
        isPincodeValid = true;
      });


    } catch (e) {
      print("Error fetching location: $e");
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
      addressController.text = data.address ?? '';
      pincodeController.text = data.pinCode?.toString() ?? '';
      stateId = data.stateId;
      cityId = data.cityId;
      districtId = data.cityDistrictId;
    });

    // Autofill location if PIN available but state/district missing
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
                    child: Text(
                      'Sales Registration Form',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
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

                  buildLabel('Address'),
                  buildTextField(addressController),

                  buildLabel('PIN Code'),
                  TextField(
                    controller: pincodeController,
                    maxLength: 6,
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

                  // State Dropdown
                  // State dropdown
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
                        child: Text(d['name'], overflow: TextOverflow.ellipsis),
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
                        if (token == null || stateId == null || districtId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fill all details")),
                          );
                          return;
                        }

                        final request = ProfileRequest(
                          phone: widget.phoneNumber,
                          name: nameController.text,
                          firmName: "",
                          address1: addressController.text,
                          address2: "",
                          pincode: pincodeController.text,
                          stateId: stateId!,
                          districtId: districtId!,
                          cityId: cityId,
                          cityName: null,
                          panNo: "",
                          dob: "",
                          doa: "",
                          profileImage: "",
                          email: "",
                          uniqueName: "",
                        );

                        await Provider.of<ProfileProvider>(context, listen: false)
                            .updateProfile(token, request);

                        final provider = Provider.of<ProfileProvider>(context, listen: false);
                        if (provider.errorMessage == null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SalesDashboardScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed: ${provider.errorMessage}")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
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
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  Widget buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
