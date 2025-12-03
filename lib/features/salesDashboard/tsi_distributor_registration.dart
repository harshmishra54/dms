import 'dart:convert';
import 'dart:math';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/tsi_distributor_model.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/tsi_distributor_registration_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/zrt_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/tsi_retailer_registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/repositories/location_repostitory.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

class TsiDistributorRegistration extends StatefulWidget {
  const TsiDistributorRegistration({super.key});

  @override
  State<TsiDistributorRegistration> createState() =>
      _TsiDistributorRegistrationState();
}

class _TsiDistributorRegistrationState
    extends State<TsiDistributorRegistration> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _uniqueNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _firmController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _distributorCodeController =
  TextEditingController();
  final TextEditingController _licenseExpiryController =
  TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _locationFetched = false;

  int? stateId;
  int? districtId;
  int? cityId;
  String? stateName;
  String? districtName;

  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> districts = [];
  final gstFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
    LengthLimitingTextInputFormatter(15),
    UpperCaseTextFormatter(),
  ];

  final panFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
    LengthLimitingTextInputFormatter(10),
    UpperCaseTextFormatter(),
  ];

  final licenseFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
    LengthLimitingTextInputFormatter(20),
    UpperCaseTextFormatter(),
  ];


  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    _fetchStates();
    final zrtProvider = Provider.of<ZrtProvider>(context, listen: false);
    zrtProvider.fetchZRT();

    // Auto-generate unique name from distributor name
    _nameController.addListener(() {
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        final parts = name.split(' ');

        String shortName = '';
        if (parts.isNotEmpty) {
          shortName +=
              parts[0].substring(0, min(2, parts[0].length)).toUpperCase();
        }
        if (parts.length > 1) {
          shortName +=
              parts.last.substring(0, min(2, parts.last.length)).toUpperCase();
        }
        shortName = shortName.substring(0, min(4, shortName.length));

        final remainingLength = 10 - shortName.length;
        final rand = Random();
        final randomDigits =
        List.generate(remainingLength, (_) => rand.nextInt(10)).join();

        String uniqueName = '';
        int numIndex = 0;
        for (int i = 0; i < shortName.length; i++) {
          uniqueName += shortName[i];
          if (numIndex < randomDigits.length) {
            uniqueName += randomDigits[numIndex];
            numIndex++;
          }
        }
        if (numIndex < randomDigits.length) {
          uniqueName += randomDigits.substring(numIndex);
        }
        _uniqueNameController.text =
            uniqueName.padRight(10, '0').substring(0, 10);
      } else {
        _uniqueNameController.text = '';
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Please enable location services")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AutoTranslateText("Location permission denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: AutoTranslateText(
                "Location permission permanently denied. Enable from settings")),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationFetched = true;
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Failed to fetch location")),
      );
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
      final fetchedStates = await repo.fetchStates(token);
      final stateObj = fetchedStates
          .firstWhere((s) => s['id'] == fetchedStateId, orElse: () => {});
      final fetchedStateName = stateObj['name'] ?? "";

      final fetchedDistricts = await repo.fetchDistricts(token, fetchedStateId);
      final districtObj = fetchedDistricts
          .firstWhere((d) => d['id'] == fetchedDistrictId, orElse: () => {});
      final fetchedDistrictName = districtObj['name'] ?? "";

      setState(() {
        states = fetchedStates;
        districts = fetchedDistricts;
        stateId = fetchedStateId is int
            ? fetchedStateId
            : int.tryParse(fetchedStateId.toString());
        districtId = fetchedDistrictId is int
            ? fetchedDistrictId
            : int.tryParse(fetchedDistrictId.toString());
        cityId = data["city_id"] is int
            ? data["city_id"]
            : int.tryParse(data["city_id"].toString());
        stateName = fetchedStateName;
        districtName = fetchedDistrictName;
      });
    } catch (e) {
      debugPrint("Error fetching location from pincode: $e");
    }
  }

  Future<void> _selectLicenseExpiry() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formatted = "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.year.toString().substring(2)}"; // dd-MM-yy
      setState(() {
        _licenseExpiryController.text = formatted;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_locationFetched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Fetching location, please wait...")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final zrtProvider = Provider.of<ZrtProvider>(context, listen: false);
      final provider =
      Provider.of<TsiDistributorProvider>(context, listen: false);
      final zoneId = zrtProvider.zrtResponse?.data?.zoneId ?? '';
      final regionId = zrtProvider.zrtResponse?.data?.regionId ?? '';
      final territoryId = zrtProvider.zrtResponse?.data?.territoryId ?? '';

      provider.setLoading(true);

      try {
        TsiDistributorModel model = TsiDistributorModel(
          name: _nameController.text,
          uniqueName: _uniqueNameController.text,
          phoneNo: int.tryParse(_phoneController.text),
          firmName: _firmController.text,
          address: _addressController.text,
          pinCode: _pincodeController.text,
          gstNo: _gstController.text,
          zoneId: zoneId,
          regionId: regionId,
          territoryId: territoryId,
          panNo: _panController.text,
          licenseNo: _distributorCodeController.text,
          licenseexpiry: _licenseExpiryController.text,
          img: _base64Image,
          stateId: stateId,
          districtId: districtId,
          cityName: cityId != null ? cityId.toString() : null,
          tsmIds: [],
          financeLocation: [],
          financeLocations: [],
          latitude: _latitude,
          longitude: _longitude,
          isCustomer: true,
          excelFile: '',
        );

        await provider.registerDistributor(model);

        if (provider.errorMessage != null) {
          // ❌ Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: AutoTranslateText(provider.errorMessage!)),
          );
        } else if (provider.distributorResponse?.success == 1) {
          // ✅ Success → reset form and pop back
          provider.reset();
          _formKey.currentState!.reset();
          setState(() {
            _licenseExpiryController.clear();
            _base64Image = null;
          });

          Future.delayed(const Duration(milliseconds: 10), () {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          });
        }
      } finally {
        provider.setLoading(false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TsiDistributorProvider(),
      child: Consumer<TsiDistributorProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF2F2F2),
            body: Column(
              children: [
                const AppStatusBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: AutoTranslateText(
                              "Distributor Registration",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.topBarColor),
                            ),
                          ),
                          buildLabel("Name"),
                          buildTextField(_nameController),
                          buildLabel("Unique Name"),
                          buildTextField(_uniqueNameController, readOnly: true),
                          buildLabel("Phone No"),
                          TextFormField(
                            controller: _phoneController,
                            maxLength: 10, // Limit to 10 digits
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration().copyWith(counterText: ""),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Phone number is required";
                              } else if (value.length != 10) {
                                return "Phone number must be exactly 10 digits";
                              } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return "Phone number must contain only digits";
                              }
                              return null;
                            },
                          ),

                          buildLabel("Firm Name"),
                          buildTextField(_firmController),
                          buildLabel("Address"),
                          buildTextField(_addressController),
                          buildLabel("PIN Code"),
                          TextFormField(
                            controller: _pincodeController,
                            maxLength: 6,
                            keyboardType: TextInputType.number,
                            decoration:
                            _inputDecoration().copyWith(counterText: ""),
                            onChanged: (value) {
                              if (value.length == 6) {
                                _fetchLocationFromPincode(value);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.length != 6) {
                                return "Enter a valid 6-digit PIN code";
                              }
                              return null;
                            },
                          ),
                          buildLabel("State"),
                          DropdownButtonFormField<int>(
                            decoration: _inputDecoration(),
                            value: stateId,
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
                            onChanged: (value) async {
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
                            decoration: _inputDecoration(),
                            value: districtId,
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
                            onChanged: (value) {
                              setState(() {
                                districtId = value;
                              });
                            },
                          ),
                          buildLabel("GST Number"),
                          buildTextField(
                            _gstController,
                            formatters: gstFormatter,
                          ),

                          buildLabel("PAN Number"),
                          buildTextField(
                            _panController,
                            formatters: panFormatter,
                          ),

                          buildLabel("License Number"),
                          buildTextField(
                            _distributorCodeController,
                            formatters: licenseFormatter,
                          ),

                          buildLabel("License Expiry"),
                          TextFormField(
                            controller: _licenseExpiryController,
                            readOnly: true,
                            decoration: _inputDecoration().copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: _selectLicenseExpiry,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Select license expiry date";
                              }
                              return null;
                            },
                          ),
                          buildLabel("Upload Document Image"),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.camera_alt),
                                label: const AutoTranslateText("Capture"),
                              ),
                              const SizedBox(width: 12),
                              _base64Image != null
                                  ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                                  : const Icon(Icons.camera_alt,
                                  color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 24),
                          provider.isLoading
                              ? const Center(
                              child: CircularProgressIndicator())
                              : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: provider.isLoading || !_locationFetched
                                  ? null
                                  : () {
                                // Set loading immediately
                                provider.setLoading(true);

                                // Call async function, but don't use its value
                                _submitRegistration().whenComplete(() {
                                  provider.setLoading(false); // reset loading after completion
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _locationFetched ? AppColors.topBarColor : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: provider.isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const AutoTranslateText(
                                "Register",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                        ],
                      ),
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
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: AutoTranslateText(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );

  Widget buildTextField(
      TextEditingController controller, {
        bool readOnly = false,
        List<TextInputFormatter>? formatters,
      }) =>
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: _inputDecoration(),
        inputFormatters: formatters ??
            [
              LengthLimitingTextInputFormatter(50),
            ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "This field is required";
          }
          return null;
        },
      );

  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black26),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
      const BorderSide(color: AppColors.topBarColor, width: 1.5),
    ),
  );
}
