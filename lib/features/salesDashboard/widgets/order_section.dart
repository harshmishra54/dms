import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/permissions/feature_access.dart';
import 'package:TrustTags_DMS/core/permissions/feature_mapper.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/distributor_new_order_screen.dart';
import 'package:TrustTags_DMS/features/orders/provider/order_details_provider.dart';
import 'package:TrustTags_DMS/features/permissions/permissions_provider.dart';
import 'package:TrustTags_DMS/data/models/order_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;
import '../../../../core/utils/shared_prefs_helper.dart';
import 'visit_helpers.dart';

class OrderSection extends ConsumerStatefulWidget {
  final String? orderId;
  final Function(String)? onOrderPlaced;

  const OrderSection({
    super.key,
    this.orderId,
    this.onOrderPlaced,
  });

  @override
  ConsumerState<OrderSection> createState() => _OrderSectionState();
}

class _OrderSectionState extends ConsumerState<OrderSection> {
  Future<OrderDetailsResponse?>? _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails(widget.orderId);
  }

  Future<void> _loadOrderDetails(String? orderId) async {
    if (orderId == null) return;

    final roleId = await SharedPrefsHelper.getDailyRoleId();
    final requestId = await SharedPrefsHelper.getDailylocationId();

    setState(() {
      _orderDetailsFuture =
          legacy.Provider.of<OrderDetailsProvider>(context, listen: false)
              .fetchOrderDetails(
            roleId: roleId.toString(),
            id: orderId,
            requestId: requestId ?? "",
          );
    });
  }

  Future<void> _onPlaceOrderTap() async {
    // final dailyRoleId = await SharedPrefsHelper.getDailyRoleId();
    final rawRoleId = await SharedPrefsHelper.getDailyRoleId();
    final int dailyRoleId = int.tryParse(rawRoleId.toString()) ?? -1;
    debugPrint("DAILY ROLE ID: $dailyRoleId");

    FeatureAccess? requiredFeature;

    if (dailyRoleId == 1) {
      requiredFeature = FeatureAccess.placeOrderOnBehalfOfDistributer;
    } else if (dailyRoleId == 3) {
      requiredFeature = FeatureAccess.placeOrderOnBehalfOfRetailer;
    }

    debugPrint("REQUIRED FEATURE: $requiredFeature");

    if (requiredFeature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoTranslateText("You are not allowed to place order"),
        ),
      );
      return;
    }

    // 🔥 IMPORTANT FIX
    final permissionState = ref.read(permissionsProvider);

    if (permissionState.data == null) {
      debugPrint("❌ Permissions not loaded yet");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoTranslateText("Permissions not loaded yet"),
        ),
      );
      return;
    }

    // 🔍 DEBUG PRINT
    for (final f in permissionState.data!.data) {
      debugPrint(
        "FEATURE_ID=${f.featureId} "
            "MAPPED=${FeatureMapper.fromId(f.featureId)} "
            "CREATE=${f.permissions.create}",
      );
    }

    final canCreate = permissionState.data!.data.any(
          (f) =>
      FeatureMapper.fromId(f.featureId) == requiredFeature &&
          f.permissions.create == true,
    );

    debugPrint("CAN CREATE ORDER: $canCreate");

    if (!canCreate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoTranslateText(
            "You don't have permission to create order",
          ),
        ),
      );
      return;
    }

    // ✅ Permission OK → Navigate
    final newOrderId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PlaceNewOrderScreen(
          returnOrderId: true,
        ),
      ),
    );

    if (newOrderId != null && mounted) {
      widget.onOrderPlaced?.call(newOrderId);
      _loadOrderDetails(newOrderId);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- Header ----------
        buildSectionHeader("Order", _onPlaceOrderTap),
        const SizedBox(height: 8),
        buildTableHeader(),

        // ---------- Order Details ----------
        FutureBuilder<OrderDetailsResponse?>(
          future: _orderDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: AutoTranslateText(""),
              );
            }

            final products = snapshot.data!.detail ?? [];

            return Column(
              children: products.map((product) {
                return buildTableRow(
                  product.product?.name ?? "-",
                  product.qty ?? "-",
                  product.price ?? "0",
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
