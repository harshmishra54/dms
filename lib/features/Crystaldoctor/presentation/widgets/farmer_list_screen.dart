import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/data/models/farmer_form_details_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_form_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart'; // for formatting dates

class FarmerListScreen extends StatefulWidget {
  const FarmerListScreen({Key? key}) : super(key: key);

  @override
  State<FarmerListScreen> createState() => _FarmerListScreenState();
}

class _FarmerListScreenState extends State<FarmerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name'; // name, date
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmerFormDetailsProvider>(context, listen: false)
          .fetchFarmersByCreator();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmerDetail> _getFilteredAndSortedFarmers(List<FarmerDetail> farmers) {
    final query = _searchQuery.toLowerCase();
    var filtered = farmers.where((farmer) {
      if (_searchQuery.isEmpty) return true;

      final nameMatch = farmer.farmerName.toLowerCase().contains(query);
      final mobileMatch = farmer.mobileNumber.contains(query);
      final cropsMatch = farmer.crops.any((crop) =>
      crop.cropName.toLowerCase().contains(query) ||
          crop.products.any((p) => p.productName.toLowerCase().contains(query)));

      return nameMatch || mobileMatch || cropsMatch;
    }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.farmerName.compareTo(b.farmerName);
          break;
        case 'date':
          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);
          comparison = aDate.compareTo(bDate);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          const AppStatusBar(),
          Material(
            elevation: 2,
            child: Container(
              padding:
              const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 0),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Farmer Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    onSelected: (value) {
                      setState(() {
                        if (_sortBy == value) {
                          _isAscending = !_isAscending;
                        } else {
                          _sortBy = value;
                          _isAscending = true;
                        }
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'name',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 20,
                              color: _sortBy == 'name'
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text('Sort by Name'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'date',
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: _sortBy == 'date'
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text('Sort by Date'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<FarmerFormDetailsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Loading farmers...",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.topBarColor),
                            onPressed: () => provider.fetchFarmersByCreator(),
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Retry",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filteredFarmers =
                _getFilteredAndSortedFarmers(provider.farmers);

                return Column(
                  children: [
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name, mobile, crop, or product...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    // Result count
                    if (provider.farmers.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${filteredFarmers.length} farmer${filteredFarmers.length != 1 ? 's' : ''} found',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_sortBy.isNotEmpty)
                              Row(
                                children: [
                                  Text(
                                    'Sorted by $_sortBy',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Icon(
                                    _isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    const Divider(height: 1),
                    // Farmers List
                    Expanded(
                      child: filteredFarmers.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty
                                  ? Icons.agriculture
                                  : Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? "No farmers found."
                                  : "No results for '$_searchQuery'",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                                child: const Text("Clear search"),
                              ),
                            ],
                          ],
                        ),
                      )
                          : RefreshIndicator(
                        onRefresh: () =>
                            provider.fetchFarmersByCreator(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredFarmers.length,
                          itemBuilder: (context, index) {
                            final farmer = filteredFarmers[index];
                            return _FarmerCard(farmer: farmer);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Farmer Card ----------------

class _FarmerCard extends StatefulWidget {
  final FarmerDetail farmer;

  const _FarmerCard({required this.farmer});

  @override
  State<_FarmerCard> createState() => _FarmerCardState();
}

class _FarmerCardState extends State<_FarmerCard> {
  bool _isExpanded = false;
  String locationName = "Loading...";

  @override
  void initState() {
    super.initState();
    _getLocationName();
  }

  Future<void> _getLocationName() async {
    try {
      final latitude = widget.farmer.latitude;
      final longitude = widget.farmer.longitude;
      if (latitude != 0 && longitude != 0) {
        final placemarks =
        await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          setState(() {
            locationName =
            "${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}, ${placemark.country ?? ''}";
          });
        } else {
          setState(() => locationName = "Unknown location");
        }
      } else {
        setState(() => locationName = "Invalid coordinates");
      }
    } catch (e) {
      setState(() => locationName = "Location error");
    }
  }

  Color _getSeasonColor(String season) {
    switch (season.toLowerCase()) {
      case 'kharif':
        return Colors.green;
      case 'rabi':
        return Colors.orange;
      case 'zaid':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmer = widget.farmer;
    final dateFormatter = DateFormat('yyyy-MM-dd');

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.topBarColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        farmer.farmerName[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      farmer.farmerName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 24,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              // Expanded content
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.phone,
                  label: 'Mobile',
                  value: farmer.mobileNumber,
                  color: Colors.teal,
                ),
                const SizedBox(height: 8),

                // Crops & Products
                for (var crop in farmer.crops) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.eco,
                    label: 'Crop',
                    value:
                    '${crop.cropName} (${crop.areaAcres} acres, ${crop.durationMonths})',
                    color: Colors.green,
                  ),
                  if (crop.products.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Products',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...crop.products.map(
                          (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _ProductRow(
                          icon: Icons.bubble_chart,
                          product: product.productName,
                          company: product.expectedDealer,
                          duration: product.expectedMonth,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          farmer.createdAt != null
                              ? dateFormatter.format(farmer.createdAt!)
                              : 'N/A',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis, // ✅ prevents overflow
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Product Row ----------------

class _ProductRow extends StatelessWidget {
  final IconData? icon;
  final String product;
  final String company;
  final String duration;
  final Color color;

  const _ProductRow({
    this.icon,
    required this.product,
    required this.company,
    required this.duration,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$product — $company (${duration.isNotEmpty ? duration : "N/A"})',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ---------------- Info Row ----------------

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
