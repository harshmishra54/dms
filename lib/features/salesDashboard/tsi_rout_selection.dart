import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/route_asm_model.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/dist_retailer_list_for_rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/route_asm_provider.dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteSelectionScreen extends StatefulWidget {
  const RouteSelectionScreen({super.key});

  @override
  State<RouteSelectionScreen> createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  String selectedMode = "Date → Users";
  String selectedUserType = "Distributor"; // New dropdown for Retailer/Distributor
  String globalSearch = "";

  bool _isSubmitting = false;

  final TextEditingController _routeNameController = TextEditingController();

  DateTime? globalDate;

  List<String> selectedDistributors = [];
  Map<String, List<DateTime>> distributorDatesMap = {};

  List<String> selectedRetailers = [];
  Map<String, List<DateTime>> retailerDatesMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<TerritoryProvider>(context, listen: false);
    final userId = await SharedPrefsHelper.getUserId();

    if (userId != null && userId.isNotEmpty) {
      await provider.fetchDistributors(userId);
    }
    await provider.fetchRetailers(userId ?? "");
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    super.dispose();
  }

  void _toggleUser(String userId, List<String> selectedUsers) {
    setState(() {
      if (selectedUsers.contains(userId)) {
        selectedUsers.remove(userId);
      } else {
        selectedUsers.add(userId);
      }
    });
  }

  Future<void> _pickDateGlobal() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        globalDate = picked;
      });
    }
  }

  Future<void> _pickDateForUser(
      String user, Map<String, List<DateTime>> userMap) async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        userMap.putIfAbsent(user, () => []);
        if (!userMap[user]!.contains(picked)) {
          userMap[user]!.add(picked);
        }
      });
    }
  }

  void _removeDateForUser(
      String user, DateTime date, Map<String, List<DateTime>> userMap) {
    setState(() {
      userMap[user]?.remove(date);
      if (userMap[user]?.isEmpty ?? false) {
        userMap.remove(user);
      }
    });
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final routeAsmProvider =
    Provider.of<RouteAsmProvider>(context, listen: false);

    try {
      if (_routeNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AutoTranslateText("Please enter route name")),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      RouteAsmRequest request;

      if (selectedMode == "Date → Users") {
        request = RouteAsmRequest(
          typeOf: 0,
          name: _routeNameController.text.trim(),
          date: globalDate != null
              ? [globalDate!.toLocal().toString().split(' ')[0]]
              : [],
          distributorLocations:
          selectedDistributors.map((id) => LocationItem(id: id)).toList(),
          retailerLocations:
          selectedRetailers.map((id) => LocationItem(id: id)).toList(),
        );
      } else {
        request = RouteAsmRequest(
          typeOf: 1,
          name: _routeNameController.text.trim(),
          distributorLocations: distributorDatesMap.entries
              .map((e) => LocationItem(
            id: e.key,
            dates: e.value.map((d) => d.toIso8601String()).toList(),
          ))
              .toList(),
          retailerLocations: retailerDatesMap.entries
              .map((e) => LocationItem(
            id: e.key,
            dates: e.value.map((d) => d.toIso8601String()).toList(),
          ))
              .toList(),
        );
      }

      final response = await routeAsmProvider.submitRouteAsm(request);

      if (!mounted) return;

      if (response.success == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoTranslateText(response.message)),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoTranslateText("Failed: ${response.message}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoTranslateText("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final territoryProvider = Provider.of<TerritoryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const AppStatusBar(),

          // Header
          Material(
            elevation: 3,
            child: Container(
              color: Colors.white,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const AutoTranslateText("Route Selection",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          // Scrollable part
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // Route Name Input
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        controller: _routeNameController,
                        decoration: InputDecoration(
                          hintText: "Enter Route Name",
                          prefixIcon: const Icon(Icons.drive_file_rename_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),

                    // Mode Dropdown
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: DropdownButtonFormField<String>(
                        value: selectedMode,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ["Date → Users", "User → Dates"].map((mode) {
                          return DropdownMenuItem(
                            value: mode,
                            child: Text(mode, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedMode = val!),
                      ),
                    ),

                    // User Type Dropdown
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: DropdownButtonFormField<String>(
                        value: selectedUserType,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ["Distributor", "Retailer"].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedUserType = val!),
                      ),
                    ),

                    // Search Field
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search ${selectedUserType}s...",
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (val) => setState(() => globalSearch = val),
                      ),
                    ),

                    // Global Date Button
                    if (selectedMode == "Date → Users")
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _pickDateGlobal,
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: const AutoTranslateText("Pick Date"),
                            ),
                            if (globalDate != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: AutoTranslateText(
                                  "${globalDate!.toLocal()}".split(' ')[0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // Content Section (filtered by Distributor/Retailer)
                    Builder(builder: (context) {
                      final territoryProvider =
                      Provider.of<TerritoryProvider>(context);
                      if (territoryProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (selectedUserType == "Distributor") {
                        return _buildSection(
                          "Distributors",
                          territoryProvider.distributors
                              .map((d) => {
                            "id": d.id ?? "",
                            "name": d.name ?? "No Name",
                            "phone": d.phone ?? ""
                          })
                              .toList(),
                          true,
                        );
                      } else {
                        return _buildSection(
                          "Retailers",
                          territoryProvider.retailers
                              .map((r) => {
                            "id": r.id ?? "",
                            "name": r.name ?? "No Name",
                            "phone": r.phone ?? ""
                          })
                              .toList(),
                          false,
                        );
                      }
                    }),

                    // Submit Button
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: SizedBox(
                    //     width: double.infinity,
                    //     child: ElevatedButton(
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: AppColors.topBarColor,
                    //         padding: const EdgeInsets.symmetric(vertical: 14),
                    //         shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(12)),
                    //       ),
                    //       onPressed: _isSubmitting ? null : _onSubmit,
                    //       child: _isSubmitting
                    //           ? const SizedBox(
                    //         height: 22,
                    //         width: 22,
                    //         child: CircularProgressIndicator(
                    //           strokeWidth: 2,
                    //           color: Colors.white,
                    //         ),
                    //       )
                    //           : const AutoTranslateText(
                    //         "Submit",
                    //         style:
                    //         TextStyle(color: Colors.white, fontSize: 15),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.topBarColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSubmitting ? null : _onSubmit,
            child: _isSubmitting
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const AutoTranslateText(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ),

    );

  }

  Widget _buildSection(
      String title, List<Map<String, String>> currentList, bool isDistributor) {
    final filteredList = currentList
        .where((item) =>
    item["name"]!.toLowerCase().contains(globalSearch.toLowerCase()) ||
        item["phone"]!.contains(globalSearch))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoTranslateText(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (selectedMode == "Date → Users")
                _buildDateToUsersUI(filteredList, globalDate, isDistributor)
              else
                _buildUserToDatesUI(
                    filteredList,
                    isDistributor ? distributorDatesMap : retailerDatesMap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateToUsersUI(
      List<Map<String, String>> currentList,
      DateTime? selectedDate,
      bool isDistributor) {
    final selectedUsers = isDistributor ? selectedDistributors : selectedRetailers;

    return Column(
      children: currentList.map((user) {
        return Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: CheckboxListTile(
            value: selectedUsers.contains(user["id"]),
            title: Text(
              user["name"]!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: user["phone"]!.isNotEmpty ? Text(user["phone"]!) : null,
            secondary: const Icon(Icons.person, color: Colors.blueGrey),
            activeColor: Colors.green,
            onChanged: (_) => _toggleUser(user["id"]!, selectedUsers),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserToDatesUI(
      List<Map<String, String>> currentList, Map<String, List<DateTime>> userMap) {
    return Column(
      children: currentList.map((user) {
        final userId = user["id"]!;
        final name = user["name"]!;
        final phone = user["phone"]!;
        final userDates = userMap[userId] ?? [];

        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          if (phone.isNotEmpty)
                            Text(phone,
                                style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _pickDateForUser(userId, userMap),
                      icon: const Icon(Icons.add_circle,
                          color: Colors.indigo, size: 28),
                      tooltip: "Add Date",
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: -6,
                  children: userDates
                      .map((d) => Chip(
                    label: Text("${d.toLocal()}".split(' ')[0]),
                    avatar: const Icon(Icons.date_range,
                        size: 16, color: Colors.green),
                    deleteIcon: const Icon(Icons.close,
                        size: 16, color: Colors.redAccent),
                    onDeleted: () =>
                        _removeDateForUser(userId, d, userMap),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
