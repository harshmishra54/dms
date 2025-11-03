import 'package:TrustTags_DMS/data/models/customer_details_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/widgets/app_status_bar.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/models/profile_request.dart';
import '../../../data/repositories/location_repostitory.dart';
import '../../authentication/provider/profile_provider.dart';
import '../../dashboard/distributor_home_navigation.dart';

class DistributorRegistrationScreen extends StatefulWidget {
  final String phoneNumber;

  const DistributorRegistrationScreen({super.key, required this.phoneNumber});

  @override
  State<DistributorRegistrationScreen> createState() =>
      _DistributorRegistrationScreenState();
}

class _DistributorRegistrationScreenState
    extends State<DistributorRegistrationScreen> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController firmController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController distributorCodeController =
  TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();

  // IDs & Lists
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
    _fetchStates();
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

  Future<void> _fetchLocationFromPincode(String pincode) async {
    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null || token.isEmpty) return;

    try {
      final repo = LocationRepository(dioClient: DioClient());

      // 1. Get IDs from pincode API
      final data = await repo.getCityStateByPincode(token, pincode);
      final fetchedStateId = data["state_id"];
      final fetchedDistrictId = data["district_id"];
      final fetchedCityId = data["city_id"];

      // 2. Fetch all states and find the matching state
      final allStates = await repo.fetchStates(token);
      final stateObj = allStates.cast<Map<String, dynamic>?>().firstWhere(
            (s) => s?['id'] == fetchedStateId,
        orElse: () => null,
      );

      // 3. Fetch districts for this state
      final fetchedDistricts = await repo.fetchDistricts(token, fetchedStateId);
      Map<String, dynamic>? districtObj;
      try {
        districtObj = fetchedDistricts.firstWhere((d) => d['id'] == fetchedDistrictId);
      } catch (_) {
        districtObj = null;
      }

      setState(() {
        states = allStates;
        districts = fetchedDistricts;

        stateId = stateObj != null ? fetchedStateId : null;
        districtId = districtObj != null ? fetchedDistrictId : null;
        cityId = fetchedCityId;

        stateName = stateObj?['name'] ?? "";
        districtName = districtObj?['name'] ?? "";

        stateController.text = stateName ?? "";
        districtController.text = districtName ?? "";
        isPincodeValid = districtObj != null;
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        isPincodeValid = false;
        districts = [];
        districtId = null;
      });
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
      addressController.text = data.address ?? '';
      pincodeController.text = data.pinCode?.toString() ?? '';
      panController.text = data.panNo ?? '';
      gstController.text = data.gstNo ?? '';

      stateId = data.stateId;
      districtId = data.cityDistrictId;
      cityId = data.cityId;

      isPincodeValid = stateId != null && districtId != null;
    });

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Distributor Registration',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Please enter correct details. Brand may use these to communicate with you and verify your account.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),

                  buildLabel('Name'),
                  buildTextField(nameController),

                  buildLabel('Mobile Number'),
                  TextField(
                    controller: TextEditingController(text: widget.phoneNumber),
                    enabled: false,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration().copyWith(
                      fillColor: Colors.grey.shade100,
                    ),
                  ),

                  buildLabel('Firm Name'),
                  buildTextField(firmController),

                  buildLabel('Address'),
                  buildTextField(addressController),

                  buildLabel('PIN Code'),
                  TextField(
                    controller: pincodeController,
                    maxLength: 6,
                    readOnly: isPincodeValid,
                    enableInteractiveSelection: !isPincodeValid,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration().copyWith(
                      counterText: '',
                    ),
                    onChanged: (value) {
                      if (value.length == 6) {
                        _fetchLocationFromPincode(value);
                      }
                    },
                  ),

                  buildLabel('State'),
                  DropdownButtonFormField<int>(
                    value: stateId,
                    decoration: _inputDecoration(),
                    isExpanded: true,
                    items: states.map((s) => DropdownMenuItem<int>(
                      value: s['id'],
                      child: Text(s['name'], overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: isPincodeValid
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
                      setState(() => districts = fetchedDistricts);
                    },
                  ),

                  buildLabel('District'),
                  DropdownButtonFormField<int>(
                    value: districtId,
                    decoration: _inputDecoration(),
                    isExpanded: true,
                    items: districts.map((d) => DropdownMenuItem<int>(
                      value: d['id'],
                      child: Text(d['name'], overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: isPincodeValid ? null : (value) {
                      setState(() => districtId = value);
                    },
                  ),

                  buildLabel('GST Number'),
                  buildTextField(gstController),

                  buildLabel('PAN Number'),
                  buildTextField(panController),

                  buildLabel('License Number'),
                  buildTextField(distributorCodeController),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final token = await SharedPrefsHelper.getAccessToken();
                        if (token == null || stateId == null || districtId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fill all required details")),
                          );
                          return;
                        }

                        final request = ProfileRequest(
                          phone: widget.phoneNumber,
                          name: nameController.text,
                          firmName: firmController.text,
                          address1: addressController.text,
                          address2: "",
                          pincode: pincodeController.text,
                          stateId: stateId!,
                          districtId: districtId!,
                          cityId: cityId,
                          cityName: null,
                          panNo: panController.text,
                          dob: "",
                          doa: "",
                          profileImage: "",
                          email: "",
                          uniqueName: "",
                        );

                        await Provider.of<ProfileProvider>(context, listen: false)
                            .updateProfile(token, request);

                        final provider =
                        Provider.of<ProfileProvider>(context, listen: false);
                        if (provider.errorMessage == null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const DistributorHomeNavigation(),
                            ),
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
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 4),
    child:
    Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  );

  Widget buildTextField(TextEditingController controller) => TextField(
    controller: controller,
    decoration: _inputDecoration(),
  );

  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
