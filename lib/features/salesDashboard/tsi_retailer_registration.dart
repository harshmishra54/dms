import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/dist_by_Id_model.dart';
import 'package:TrustTags_DMS/data/models/taluka_model.dart';
import 'package:TrustTags_DMS/data/models/tsi_retailer_model.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/dist_by_Id_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/dist_retailer_list_for_rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/retailer_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/taluka_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/zrt_provider.dart';
import 'package:TrustTags_DMS/widgets/distributor_dropdown_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/repositories/location_repostitory.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}


class TsiRetailerRegistration extends StatefulWidget {
  const TsiRetailerRegistration({super.key});

  @override
  State<TsiRetailerRegistration> createState() =>
      _TsiRetailerRegistrationState();
}

class _TsiRetailerRegistrationState extends State<TsiRetailerRegistration> {
  final _formKey = GlobalKey<FormState>();
  List<DistributorData> _selectedDistributors = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _uniqueNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _firmController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _retailerCodeController = TextEditingController();
  final TextEditingController _licenceExpiryController= TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _locationFetched = false;
  bool _isSubmitting = false; // ✅ loader flag

  int? stateId;
  int? districtId;
  int? cityId;
  String? stateName;
  String? districtName;
  TalukaData? selectedTaluka;

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




  @override
  void initState() {
    super.initState();
    _initializeScreen();
    Future.microtask(() async {
      final zrtProvider = Provider.of<ZrtProvider>(context, listen: false);
      await zrtProvider.fetchZRT();

      final territoryId = zrtProvider.zrtResponse?.data?.territoryId;
      final userId=await SharedPrefsHelper.getUserId();
      if (userId != null) {
        final distributorProvider =
        Provider.of<TerritoryProvider>(context, listen: false);
        await distributorProvider.fetchDistributors(userId??"");
      }
    });
  }

  Future<void> _initializeScreen() async {
    await _getCurrentLocation();
    await _fetchStates();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationFetched = true;
      });

      debugPrint("✅ Location: $_latitude, $_longitude");
    } catch (e) {
      debugPrint("❌ Error fetching location: $e");
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

  Future<void> _fetchTalukaSilently() async {
    final zrtProvider = Provider.of<ZrtProvider>(context, listen: false);
    final talukaProvider = Provider.of<TalukaProvider>(context, listen: false);

    final territoryId = zrtProvider.zrtResponse?.data?.territoryId;
    final districtIdStr = districtId?.toString();

    if (territoryId != null && districtIdStr != null) {
      await talukaProvider.fetchTaluka(
        territoryId: territoryId,
        districtId: districtIdStr,
      );
      if (!talukaProvider.talukaList.contains(selectedTaluka)) {
        setState(() {
          selectedTaluka = null;
        });
      }
      debugPrint(
          "✅ Taluka fetched silently: ${talukaProvider.talukaList.length}");
    }
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
        stateId = int.tryParse(fetchedStateId.toString());
        districtId = int.tryParse(fetchedDistrictId.toString());
        cityId = int.tryParse(data["city_id"].toString());
        stateName = fetchedStateName;
        districtName = fetchedDistrictName;
      });
      _fetchTalukaSilently();
    } catch (e) {
      debugPrint("❌ Error fetching location from pincode: $e");
    }
  }

  Future<void> _submitRegistration() async {
    if (_isSubmitting) return; // ✅ extra guard
    setState(() {
      _isSubmitting = true; // ✅ lock instantly
    });

    if (!_locationFetched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Fetching location, please wait...")),
      );
      setState(() => _isSubmitting = false); // unlock
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = false); // unlock
      return;
    }

    final selectedDistributors = _selectedDistributors;
    if (selectedDistributors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Please select at least one distributor")),
      );
      setState(() => _isSubmitting = false); // unlock
      return;
    }

    final zrtProvider = Provider.of<ZrtProvider>(context, listen: false);
    final territoryId = zrtProvider.zrtResponse?.data?.territoryId ?? '';
    final zoneId = zrtProvider.zrtResponse?.data?.zoneId ?? '';
    final regionId = zrtProvider.zrtResponse?.data?.regionId ?? '';

    final request = RetailerRequest(
      type: '3',
      name: _nameController.text.trim(),
      dob: _dobController.text.trim(),
      phone: int.tryParse(_phoneController.text.trim()) ?? 0,
      address: _addressController.text.trim(),
      Pincode: _pincodeController.text.trim(),
      zoneId: zoneId,
      regionId: regionId,
      territoryId: territoryId,
      districtId: districtId?.toString() ?? '',
      talukaId: selectedTaluka?.id.toString() ?? '',
      stateId: stateId?.toString() ?? '',
      cityId: cityId?.toString() ?? '',
      latitude: _latitude ?? 0.0,
      longitude: _longitude ?? 0.0,
      distributorIds: selectedDistributors
          .map((d) => RetailerDistributor(id: d.id, name: d.name ?? "Unknown"))
          .toList(),
      panNo: _panController.text.trim(),
      gstNo: _gstController.text.trim(),
      priFirm: _firmController.text.trim(),
      secFirms: [],
      secNums: [],
      estDate: _dateController.text.trim(),
      isZrtBased: true,
      licenseNo: _retailerCodeController.text,
      licenceEpiry: _licenceExpiryController.text,
    );

    final retailerProvider =
    Provider.of<RetailerProvider>(context, listen: false);

    await retailerProvider.registerRetailer(request);

    if (retailerProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText("❌ ${retailerProvider.errorMessage}")),
      );
    } else if (retailerProvider.retailerResponse != null &&
        retailerProvider.retailerResponse!.success.toString() == "1") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            AutoTranslateText(retailerProvider.retailerResponse!.message ?? "Success ✅")),
      );

      _formKey.currentState!.reset();
      setState(() {
        selectedTaluka = null;
        _selectedDistributors = [];
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.of(context).pop(true);
      });
    }

    setState(() {
      _isSubmitting = false; // ✅ unlock when done
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          const AppStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: AutoTranslateText(
                        "Retailer Registration",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.topBarColor),
                      ),
                    ),
                    buildLabel("Name"),
                    buildTextField(_nameController),
                    buildLabel("Date of Birth"),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: _inputDecoration().copyWith(
                        hintText: "Enter Date of Birth",
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(), // default DOB
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dobController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}/"
                                "${pickedDate.month.toString().padLeft(2, '0')}/"
                                "${pickedDate.year}";
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Date of Birth";
                        }
                        return null;
                      },
                    ),

                    buildLabel("Established Date"),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: _inputDecoration().copyWith(
                        hintText: "Select Established Date",
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dateController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}/"
                                "${pickedDate.month.toString().padLeft(2, '0')}/"
                                "${pickedDate.year}";
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select Established Date";
                        }
                        return null;
                      },
                    ),

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
                      decoration: _inputDecoration().copyWith(counterText: ""),
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

                    buildLabel("Licence No"),
                    buildTextField(
                      _retailerCodeController,
                      formatters: licenseFormatter,
                    ),

                    buildLabel("Licence Expiry"),
                    TextFormField(
                      controller: _licenceExpiryController,
                      readOnly: true,
                      decoration: _inputDecoration().copyWith(
                        hintText: "Enter Licence Expiry",
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(), // default DOB
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2200),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _licenceExpiryController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}/"
                                "${pickedDate.month.toString().padLeft(2, '0')}/"
                                "${pickedDate.year}";
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Licence Expiry";
                        }
                        return null;
                      },
                    ),
                    buildLabel("Taluka"),
                    Consumer<TalukaProvider>(
                      builder: (context, talukaProvider, child) {
                        if (talukaProvider.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final talukas = talukaProvider.talukaList;

                        if (talukas.isEmpty) {
                          return const AutoTranslateText("No Taluka available");
                        }

                        return DropdownButtonFormField<TalukaData>(
                          decoration: _inputDecoration(),
                          value: selectedTaluka,
                          isExpanded: true,
                          items: talukas.map((t) {
                            return DropdownMenuItem<TalukaData>(
                              value: t,
                              child: Text(t.name),
                            );
                          }).toList(),
                          onChanged: (t) {
                            setState(() {
                              selectedTaluka = t;
                            });
                          },
                          validator: (value) {
                            if (value == null) return "Please select a Taluka";
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Consumer<TerritoryProvider>(
                      builder: (context, distributorProvider, child) {
                        if (distributorProvider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (distributorProvider.errorMessage != null) {
                          return Text(
                              "❌ Error: ${distributorProvider.errorMessage}");
                        }

                        final distributors =
                            distributorProvider.distributors?? [];

                        if (distributors.isEmpty) {
                          return const AutoTranslateText("No distributors found");
                        }

                        final distributorItems = distributors
                            .map((d) =>
                        {"id": d.id, "name": d.name ?? "Unknown"})
                            .toList();

                        return MultiSelectDropdownWithSearch(
                          label: "Distributors",
                          items: distributorItems,
                          onSelectionChanged: (selected) {
                            setState(() {
                              _selectedDistributors = selected.map((e) {
                                final map = e as Map<String, dynamic>;
                                return DistributorData(
                                  id: map['id'],
                                  name: map['name'],
                                );
                              }).toList();
                            });
                            debugPrint(
                                "Selected distributors: $_selectedDistributors");
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                        (!_locationFetched || _isSubmitting) ? null : _submitRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _locationFetched
                              ? AppColors.topBarColor
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
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
        List<TextInputFormatter>? formatters,
      }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(),
      inputFormatters: formatters ??
          [
            LengthLimitingTextInputFormatter(50), // default
          ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required";
        }
        return null;
      },
    );
  }


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
