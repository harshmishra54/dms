import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/permissions/feature_access.dart';
import 'package:TrustTags_DMS/core/permissions/feature_mapper.dart';
import 'package:TrustTags_DMS/data/models/to_location_response.dart';
import 'package:TrustTags_DMS/features/permissions/permissions_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/return_order_details_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/visit_helpers.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:TrustTags_DMS/features/authentication/provider/distributor_provider.dart';
import 'package:TrustTags_DMS/features/returns/Add_return_order.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class RaiseReturnClaimSection extends StatefulWidget {
  final String? returnOrderId;
  final Function(String)? onAddReturnOrderPlaced;

  const RaiseReturnClaimSection({
    super.key,
    this.returnOrderId,
    this.onAddReturnOrderPlaced,
  });

  @override
  State<RaiseReturnClaimSection> createState() =>
      _RaiseReturnClaimSectionState();
}

class _RaiseReturnClaimSectionState extends State<RaiseReturnClaimSection> {
  @override
  void initState() {
    super.initState();
    // Initial fetch if returnOrderId is present
    if (widget.returnOrderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchReturnOrderDetails();
      });
    }
  }

  // ✅ Trigger API when returnOrderId changes
  @override
  void didUpdateWidget(covariant RaiseReturnClaimSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.returnOrderId != widget.returnOrderId &&
        widget.returnOrderId != null) {
      _fetchReturnOrderDetails();
    }
  }

  Future<void> _fetchReturnOrderDetails() async {
    final provider =
    legacy.Provider.of<ReturnOrderDetailsProvider>(context, listen: false);

    final roleId = await SharedPrefsHelper.getDailyRoleId();
    final requestId = await SharedPrefsHelper.getDailylocationId();

    await provider.fetchReturnOrderDetails(
      orderId: widget.returnOrderId!,
      roleId: roleId ?? "",
      requestId: requestId ?? "",
    );
  }


  void _showDistributorDialog(BuildContext context) async {
    final distributorProvider =
    legacy.Provider.of<DistributorProviders>(context, listen: false);

    final dailyRoleId = await SharedPrefsHelper.getDailyRoleId();

    await distributorProvider.fetchDistributors();
    final distributors = distributorProvider.distributors;

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: distributorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : distributors.isEmpty
                  ? const Center(child: AutoTranslateText("No distributors found"))
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownSearch<DistributorData>(
                    items: distributors,
                    itemAsString: (DistributorData d) => d.name ?? "",
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: (dailyRoleId == "1")
                              ? "Search CFA..."
                              : "Search distributor...",
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: (dailyRoleId == "1")
                            ? "Select CFA"
                            : "Select Distributor",
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                    onChanged: (DistributorData? distributor) async {
                      if (distributor == null) return;
                      Navigator.pop(context);

                      debugPrint(
                          "✅ Selected Distributor: ${distributor.name} (ID: ${distributor.id})");

                      final result = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddReturnOrderScreen(
                            distributorName: distributor.name,
                            distributorId: distributor.id,
                          ),
                        ),
                      );

                      if (result != null &&
                          widget.onAddReturnOrderPlaced != null) {
                        widget.onAddReturnOrderPlaced!(result);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return legacy.Consumer<ReturnOrderDetailsProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================== HEADER ==================
            buildSectionHeader(
              "Raise Return Claim",
                  () async {
                final rawRoleId = await SharedPrefsHelper.getDailyRoleId();
                final int dailyRoleId =
                    int.tryParse(rawRoleId.toString()) ?? -1;

                FeatureAccess? requiredFeature;

                // 🔑 Decide feature by DAILY role
                if (dailyRoleId == 1) {
                  requiredFeature = FeatureAccess.distributerReturn;
                } else if (dailyRoleId == 3) {
                  requiredFeature = FeatureAccess.retailerReturn;
                }

                if (requiredFeature == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: AutoTranslateText(
                        "You are not allowed to raise return",
                      ),
                    ),
                  );
                  return;
                }

                final permissionState =
                ProviderScope.containerOf(context)
                    .read(permissionsProvider);

                if (permissionState.data == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: AutoTranslateText(
                        "Permissions not loaded yet",
                      ),
                    ),
                  );
                  return;
                }

                final canCreate = permissionState.data!.data.any(
                      (f) =>
                  FeatureMapper.fromId(f.featureId) ==
                      requiredFeature &&
                      f.permissions.create == true,
                );

                if (!canCreate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: AutoTranslateText(
                        "You don't have permission to create return",
                      ),
                    ),
                  );
                  return;
                }

                // ✅ Permission OK
                _showDistributorDialog(context);
              },
            ),

            const SizedBox(height: 8),

            // ================== RETURN DETAILS ==================
            if (widget.returnOrderId != null)
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? AutoTranslateText(
                "Error: ${provider.error}",
                style: const TextStyle(color: Colors.red),
              )
                  : provider.orderDetails == null ||
                  provider.orderDetails!.detail == null ||
                  provider.orderDetails!.detail!.isEmpty
                  ? const AutoTranslateText("No details available")
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  buildTableHeader(),
                  ...provider.orderDetails!.detail!.map(
                        (item) => buildTableRow(
                      "${item.product.name}\n(${item.product.id})",
                      item.qty.toString(),
                      item.price.toString(),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

}
