import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/crystal_doctor_dashboard.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/retailer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/tsi_retailer_model.dart';
import 'package:TrustTags_DMS/data/repositories/location_repostitory.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/widgets/app_status_bar.dart';// <-- Import your provider

class RegisterFarmerByCrystalDoctor extends StatefulWidget {
  const RegisterFarmerByCrystalDoctor({super.key});

  @override
  State<RegisterFarmerByCrystalDoctor> createState() =>
      _RegisterFarmerByCrystalDoctorState();
}

class _RegisterFarmerByCrystalDoctorState
    extends State<RegisterFarmerByCrystalDoctor> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();


  double? _latitude;
  double? _longitude;
  String? _locationName;

  int? stateId;
  int? districtId;
  int? cityId;
  bool isPincodeValid = false;

  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> districts = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _fetchStates();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
      _fetchLocationNameFromLatLong(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  Future<void> _fetchLocationNameFromLatLong(double lat, double long) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _locationName =
          "${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}";
        });
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");
    }
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
    if (pincode.length != 6) return;

    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null) return;

    try {
      final repo = LocationRepository(dioClient: DioClient());
      final data = await repo.getCityStateByPincode(token, pincode);

      final fetchedStateId = data["state_id"];
      final fetchedDistrictId = data["district_id"];
      final fetchedCityId = data["city_id"];

      final fetchedStates = await repo.fetchStates(token);
      final fetchedDistricts = await repo.fetchDistricts(token, fetchedStateId);

      setState(() {
        states = fetchedStates;
        districts = fetchedDistricts;
        stateId = fetchedStateId;
        districtId = fetchedDistrictId;
        cityId = fetchedCityId;
        isPincodeValid = true;
      });
    } catch (e) {
      debugPrint("Error fetching location from pincode: $e");
      setState(() {
        stateId = null;
        districtId = null;
        cityId = null;
        districts = [];
        isPincodeValid = false;
      });
    }
  }
  void _registerFarmer(BuildContext context) async {
    final provider = Provider.of<RetailerProvider>(context, listen: false);

    if (_nameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _mobileController.text.length != 10 ||
        !_mobileController.text.contains(RegExp(r'^[0-9]+$')) ||
        _addressController.text.isEmpty ||
        stateId == null ||
        districtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Please enter a valid 10-digit mobile number and fill all required fields")),
      );
      return;
    }


    // Get userId (requestId) from SharedPrefs
    final requestedId = await SharedPrefsHelper.getUserId();

    final dob = _dobController.text;
    final area = _areaController.text;

    final request = RetailerRequest(
      type: "23",
      name: _nameController.text,
      dob: dob,
      phone: int.tryParse(_mobileController.text) ?? 0,
      address: _addressController.text,
      stateId: stateId?.toString() ?? "",
      districtId: districtId?.toString(),
      cityId: cityId?.toString() ?? "",
      latitude: _latitude ?? 0.0,
      longitude: _longitude ?? 0.0,
      distributorIds: [],
      requestedId: requestedId,
      area: area,
      Pincode: _pincodeController.text,
      requestId: requestedId,
    );

    await provider.registerRetailer(request);

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText("Error: ${provider.errorMessage}")),
      );
    } else {
      // Show success SnackBar first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Farmer registered successfully")),
      );

      // Wait a short duration to show the SnackBar
      await Future.delayed(const Duration(seconds: 1));

      // Reset fields
      provider.reset();
      _nameController.clear();
      _mobileController.clear();
      _addressController.clear();
      _pincodeController.clear();
      setState(() {
        stateId = null;
        districtId = null;
        cityId = null;
        districts = [];
        isPincodeValid = false;
      });

      // Navigate to CrystalDoctorDashboard
      Navigator.pop(context);

    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RetailerProvider>(
      create: (_) => RetailerProvider(),
      child: Consumer<RetailerProvider>(
        builder: (context, provider, child) {
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
                            'Farmer Registration',
                            style: TextStyle(fontSize: 20, color: Colors.black87),
                          ),
                        ),
                        if (_locationName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: AutoTranslateText(
                              "Current Location: $_locationName",
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        buildLabel("Name"),
                        buildTextField(_nameController),
                        buildLabel("Mobile Number"),
                        TextField(
                          controller: _mobileController,
                          maxLength: 10, // limit to 10 digits
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // allow only numbers
                          ],
                          decoration: _inputDecoration().copyWith(
                            counterText: "",
                            hintText: "Enter 10-digit mobile number",
                          ),
                          onChanged: (value) {
                            if (value.length > 10) {
                              _mobileController.text = value.substring(0, 10);
                              _mobileController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _mobileController.text.length),
                              );
                            }
                          },
                        ),

                        buildLabel("Address"),
                        buildTextField(_addressController),
                        buildLabel("Date of Birth"),
                        TextField(
                          controller: _dobController,
                          readOnly: true, // Prevent manual input
                          decoration: _inputDecoration().copyWith(
                            hintText: "DD/MM/YYYY",
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000, 1, 1),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              // Format date as dd/MM/yyyy
                              final formattedDate =
                                  "${pickedDate.day.toString().padLeft(2,'0')}/${pickedDate.month.toString().padLeft(2,'0')}/${pickedDate.year}";
                              setState(() {
                                _dobController.text = formattedDate;
                              });
                            }
                          },
                        ),


                        buildLabel("Area (in acres)"),
                        TextField(
                          controller: _areaController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration().copyWith(
                            hintText: "Enter area in acres",
                          ),
                        ),

                        buildLabel("PIN Code"),
                        TextField(
                          controller: _pincodeController,
                          maxLength: 6,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration().copyWith(counterText: ""),
                          onChanged: (value) {
                            if (value.length == 6) {
                              _fetchLocationFromPincode(value);
                            }
                          },
                        ),
                        buildLabel("State"),
                        DropdownButtonFormField<int>(
                          value: stateId,
                          decoration: _inputDecoration(),
                          isExpanded: true,
                          items: states
                              .map((s) => DropdownMenuItem<int>(
                            value: s['id'],
                            child: AutoTranslateText(
                              s['name'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                              .toList(),
                          onChanged: isPincodeValid
                              ? null
                              : (value) async {
                            if (value == null) return;
                            setState(() {
                              stateId = value;
                              districtId = null;
                              districts = [];
                            });
                            await _fetchDistrictsForState(value);
                          },
                        ),
                        buildLabel("District"),
                        DropdownButtonFormField<int>(
                          value: districtId,
                          decoration: _inputDecoration(),
                          isExpanded: true,
                          items: districts
                              .map((d) => DropdownMenuItem<int>(
                            value: d['id'],
                            child: AutoTranslateText(
                              d['name'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                              .toList(),
                          onChanged: isPincodeValid
                              ? null
                              : (value) {
                            setState(() {
                              districtId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () => _registerFarmer(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: provider.isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const AutoTranslateText(
                              'Register Farmer',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
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
        },
      ),
    );
  }

  Widget buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 16),
    child: AutoTranslateText(text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
  );

  Widget buildTextField(TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(),
      );

  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    filled: true,
    fillColor: Colors.grey.shade100,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.black26),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:
      const BorderSide(color: AppColors.primaryPurple, width: 1.5),
    ),
  );
}
