import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/data/models/add_farmer_details_model.dart';
import 'package:TrustTags_DMS/data/models/crop_list_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/register_farmer_by_crystal_doctor.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/add_farmer_details_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/crop_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/list_farmer_details_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/update_beat_plan_doctor_individual_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class FarmerMeetingScreen extends StatefulWidget {
  final String? farmerId; // ✅ Added farmer ID
  final String? farmerPhone; // ✅ Added farmer phone
  final bool shouldPopOnSuccess;
  final String? routeId;
  final VoidCallback? onSubmitSuccess;

  const FarmerMeetingScreen({
    Key? key,
    this.farmerId, // ✅ Optional farmer ID
    this.farmerPhone, // ✅ Optional farmer phone
    this.shouldPopOnSuccess = true,
    this.routeId,
    this.onSubmitSuccess,
  }) : super(key: key);

  @override
  State<FarmerMeetingScreen> createState() => _FarmerMeetingScreenState();
}

class _FarmerMeetingScreenState extends State<FarmerMeetingScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _farmerNameController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _nearestRetailer;

  String? _selectedSeason;
  List<CropEntry> _selectedCrops = [];

  double? _latitude;
  double? _longitude;
  bool _isFetchingLocation = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _seasons = [
    'Kharif (Monsoon)',
    'Rabi (Winter)',
    'Zaid (Summer)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLocationSilently();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    Future.microtask(() {
      Provider.of<CropProvider>(context, listen: false).fetchCropList();
    });

    // ✅ Auto-fill mobile number if provided
    if (widget.farmerPhone != null && widget.farmerPhone!.isNotEmpty) {
      _mobileController.text = widget.farmerPhone!;
      // ✅ Fetch farmer details immediately
      _fetchFarmerDetailsOnInit();
    }

    _mobileController.addListener(_onMobileChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mobileController.removeListener(_onMobileChanged);
    _mobileController.dispose();
    _farmerNameController.dispose();
    for (var crop in _selectedCrops) {
      crop.dispose();
    }
    super.dispose();
  }

  // ✅ Fetch farmer details when screen loads (if phone is provided)
  Future<void> _fetchFarmerDetailsOnInit() async {
    final phone = widget.farmerPhone;
    if (phone == null || phone.isEmpty) return;

    final farmerProvider = Provider.of<FarmerDetailsProvider>(context, listen: false);
    await farmerProvider.fetchFarmerDetails(phone);

    if (farmerProvider.farmerDetails?.success == 1 &&
        farmerProvider.farmerDetails?.data != null) {
      final farmer = farmerProvider.farmerDetails!.data!;
      setState(() {
        _farmerNameController.text = farmer.name ?? '';
        _nearestRetailer = farmer.nearestRetailer?.name;
        for (var crop in _selectedCrops) {
          for (var product in crop.products) {
            product.expectedDealerController.text = _nearestRetailer ?? '';
          }
        }
      });
    } else if (farmerProvider.farmerDetails?.success == 0 &&
        farmerProvider.farmerDetails?.message == "Farmer not found Please Register!") {
      _showSnack('Farmer not found! Please Register...', icon: Icons.info_outline);
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RegisterFarmerByCrystalDoctor(),
          ),
        );
      });
    } else {
      _showSnack('Unable to fetch farmer details', icon: Icons.error_outline);
    }
  }

  Future<void> _fetchLocationSilently() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _isFetchingLocation = false;
      });
    } catch (e) {
      setState(() => _isFetchingLocation = false);
      debugPrint('Location Error: $e');
    }
  }

  void _onMobileChanged() async {
    final phone = _mobileController.text.trim();

    if (phone.length == 10) {
      final farmerProvider = Provider.of<FarmerDetailsProvider>(context, listen: false);
      await farmerProvider.fetchFarmerDetails(phone);

      if (farmerProvider.farmerDetails?.success == 1 &&
          farmerProvider.farmerDetails?.data != null) {
        final farmer = farmerProvider.farmerDetails!.data!;
        setState(() {
          _farmerNameController.text = farmer.name ?? '';
          _nearestRetailer = farmer.nearestRetailer?.name;
          for (var crop in _selectedCrops) {
            for (var product in crop.products) {
              product.expectedDealerController.text = _nearestRetailer ?? '';
            }
          }
        });
      } else if (farmerProvider.farmerDetails?.success == 0 &&
          farmerProvider.farmerDetails?.message == "Farmer not found Please Register!") {
        _showSnack('Farmer not found! Please Register...', icon: Icons.info_outline);
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisterFarmerByCrystalDoctor(),
            ),
          );
        });
      } else {
        setState(() {
          _farmerNameController.clear();
          _nearestRetailer = null;
          for (var crop in _selectedCrops) {
            for (var product in crop.products) {
              product.expectedDealerController.clear();
            }
          }
        });
        _showSnack('Unable to fetch farmer details', icon: Icons.error_outline);
      }
    } else if (phone.length < 10) {
      setState(() {
        _farmerNameController.clear();
        _nearestRetailer = null;
        for (var crop in _selectedCrops) {
          for (var product in crop.products) {
            product.expectedDealerController.clear();
          }
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrops.isEmpty) {
      _showSnack('Please select at least one crop', icon: Icons.warning_amber);
      return;
    }
    if (_selectedSeason == null) {
      _showSnack('Please select a season', icon: Icons.warning_amber);
      return;
    }
    if (_latitude == null || _longitude == null) {
      _showSnack('Unable to get location, please enable GPS', icon: Icons.location_off);
      return;
    }

    List<CropDetail> cropDetails = [];
    for (var crop in _selectedCrops) {
      List<ProductDetail> products = crop.products.map((p) {
        return ProductDetail(
          productName: p.productNameController.text,
          currentlyUsing: p.currentlyUsing,
          interestLevel: p.interestLevel,
          expectedQuantity: int.tryParse(p.expectedQuantityController.text) ?? 0,
          expectedMonth: p.expectedMonthController.text,
          expectedDealer: p.expectedDealerController.text,
          remarks: p.remarksController.text,
        );
      }).toList();

      cropDetails.add(CropDetail(
        cropName: crop.cropName,
        areaAcres: double.tryParse(crop.areaController.text) ?? 0,
        durationMonths: crop.durationController.text,
        products: products,
      ));
    }

    final createdBy = await SharedPrefsHelper.getUserId();
    if (createdBy == null || createdBy.isEmpty) {
      _showSnack('User not found, please login again.', icon: Icons.person_off);
      return;
    }

    final request = AddFarmerRequest(
      farmerName: _farmerNameController.text,
      mobileNumber: _mobileController.text,
      crops: cropDetails,
      createdBy: createdBy,
      latitude: _latitude!,
      longitude: _longitude!,
      season: _selectedSeason!,
    );

    final provider = Provider.of<AddFarmerProvider>(context, listen: false);
    await provider.addFarmer(request);

    if (provider.errorMessage != null) {
      _showSnack(provider.errorMessage!, icon: Icons.error_outline);
      return; // ✅ ADD THIS LINE
    }

    if (provider.response != null) {
      _showSnack(provider.response!.message, color: Colors.green, icon: Icons.check_circle); // ✅ CHANGE COLOR TO GREEN

      // ✅ ADD THIS ENTIRE BLOCK
      if (widget.routeId != null && widget.farmerId != null) {
        final individualProvider = Provider.of<UpdateBeatPlanDoctorIndividualProvider>(
          context,
          listen: false,
        );

        await individualProvider.updateBeatPlanDoctorIndividual(
          id: widget.routeId!,
          status: 'Completed',
          fid: widget.farmerId!,
        );

        if (individualProvider.message != null) {
          _showSnack(
            individualProvider.message!,
            color: Colors.blue,
            icon: Icons.info,
          );
        }
      }
      // ✅ END OF NEW BLOCK

      _formKey.currentState!.reset();
      setState(() {
        _selectedCrops.clear();
        _selectedSeason = null;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, true); // ✅ CHANGE FROM Navigator.pop(context) TO Navigator.pop(context, true)
      });
    }
  }
  void _showSnack(String message, {Color color = Colors.red, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cropProvider = Provider.of<CropProvider>(context);
    final List<CropData> availableCrops = cropProvider.cropResponse?.data ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const AppStatusBar(),
          _buildAppBar(),
          Expanded(
            child: cropProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFarmerSection(),
                      const SizedBox(height: 16),
                      _buildCropSection(availableCrops),
                      const SizedBox(height: 16),
                      _submitButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Material(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Visit Rout Details',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person, color: Colors.purple.shade700, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Farmer Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label('Mobile Number', icon: Icons.phone_android),
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            readOnly: widget.farmerPhone != null, // ✅ Make read-only if pre-filled
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)
            ],
            decoration: _decor(
              'Enter 10-digit mobile number',
              prefixIcon: Icons.phone,
              fillColor: widget.farmerPhone != null ? Colors.grey.shade50 : Colors.white,
            ),
            validator: (val) => val == null || val.isEmpty ? 'Enter Mobile Number' : null,
          ),
          const SizedBox(height: 12),
          _label('Farmer Name', icon: Icons.person_outline),
          TextFormField(
            controller: _farmerNameController,
            readOnly: true,
            decoration: _decor('Auto-filled from mobile',
              prefixIcon: Icons.person,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          _label('Season', icon: Icons.wb_sunny_outlined),
          _buildSeasonSelector(),
          if (_latitude != null && _longitude != null)
            _buildLocationChip(),
        ],
      ),
    );
  }

  Widget _buildSeasonSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _seasons.map((season) {
        final isSelected = _selectedSeason == season;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedSeason = season;
              _selectedCrops.clear();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              )
                  : null,
              color: isSelected ? null : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.purple.shade600 : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              season,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationChip() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: Colors.purple.shade700, size: 14),
          const SizedBox(width: 4),
          Text(
            'Location: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
            style: TextStyle(
              color: Colors.purple.shade900,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropSection(List<CropData> availableCrops) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.agriculture, color: Colors.amber.shade700, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Crop Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownSearch<String>(
                items: availableCrops
                    .map((e) => e.cropTypeName)
                    .where((c) => !_selectedCrops.map((s) => s.cropName).contains(c))
                    .toList(),
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Search crops...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: _decor('Select Crop to Add', prefixIcon: Icons.add_circle_outline),
                ),
                onChanged: (String? crop) {
                  if (crop != null) {
                    setState(() {
                      _selectedCrops.add(
                        CropEntry(cropName: crop, nearestRetailer: _nearestRetailer),
                      );
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._selectedCrops.asMap().entries.map((entry) => _cropCard(entry.value, entry.key)).toList(),
      ],
    );
  }

  Widget _cropCard(CropEntry crop, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade500, Colors.purple.shade700],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    crop.cropName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                  onPressed: () => setState(() => _selectedCrops.removeAt(index)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Area (Acres)', icon: Icons.square_foot, small: true),
                          TextFormField(
                            controller: crop.areaController,
                            keyboardType: TextInputType.number,
                            decoration: _decor('0.0', compact: true),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Duration (Months)', icon: Icons.calendar_today, small: true),
                          TextFormField(
                            controller: crop.durationController,
                            decoration: _decor('e.g., 4-5', compact: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...crop.products.asMap().entries.map((e) => _productCard(e.value, crop, e.key)).toList(),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      final newProduct = ProductEntry();
                      newProduct.expectedDealerController.text = _nearestRetailer ?? '';
                      crop.products.add(newProduct);
                    });
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Product', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple.shade700,
                    side: BorderSide(color: Colors.purple.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(ProductEntry product, CropEntry crop, int productIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_bag, size: 14, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text(
                  'Product ${productIndex + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                if (crop.products.length > 1)
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: Colors.red.shade400),
                    onPressed: () => setState(() => crop.products.removeAt(productIndex)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextFormField(
                  controller: product.productNameController,
                  decoration: _decor('Product Name', compact: true, prefixIcon: Icons.label),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SwitchListTile(
                    title: const Text('Currently Using', style: TextStyle(fontSize: 13)),
                    value: product.currentlyUsing,
                    onChanged: (val) => setState(() => product.currentlyUsing = val),
                    activeColor: Colors.purple.shade600,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    dense: true,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: product.interestLevel,
                  items: ['High', 'Medium', 'Low']
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: e == 'High'
                              ? Colors.red
                              : e == 'Medium'
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(e, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => product.interestLevel = val);
                  },
                  decoration: _decor('Interest Level', compact: true, prefixIcon: Icons.favorite),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: product.expectedDealerController,
                  readOnly: true,
                  enableInteractiveSelection: false,
                  showCursor: false,
                  decoration: _decor('Expected Dealer', compact: true, prefixIcon: Icons.store),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: product.expectedMonthController,
                  decoration: _decor('Expected Month', compact: true),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: product.remarksController,
                  decoration: _decor('Remarks (Optional)', compact: true),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade500, Colors.purple.shade700],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Submit Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, {IconData? icon, bool small = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 13 : 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: small ? 12 : 13,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decor(String hint, {IconData? prefixIcon, bool compact = false, Color? fillColor}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: fillColor ?? Colors.white,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: Colors.grey.shade600) : null,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: compact ? 10 : 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}

// ---------------- Models for Form ----------------

class CropEntry {
  final String cropName;
  TextEditingController areaController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  List<ProductEntry> products = [ProductEntry()];

  CropEntry({required this.cropName, String? nearestRetailer})
      : products = [ProductEntry(nearestRetailer: nearestRetailer)];

  void dispose() {
    areaController.dispose();
    durationController.dispose();
    for (var p in products) p.dispose();
  }
}

class ProductEntry {
  TextEditingController productNameController = TextEditingController();
  bool currentlyUsing = false;
  String interestLevel = 'Medium';
  TextEditingController expectedQuantityController = TextEditingController();
  TextEditingController expectedMonthController = TextEditingController();
  TextEditingController expectedDealerController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  ProductEntry({String? nearestRetailer}) {
    expectedDealerController.text = nearestRetailer ?? '';
  }

  void dispose() {
    productNameController.dispose();
    expectedQuantityController.dispose();
    expectedMonthController.dispose();
    expectedDealerController.dispose();
    remarksController.dispose();
  }
}