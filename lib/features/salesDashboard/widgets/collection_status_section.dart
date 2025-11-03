import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/authentication/provider/rout_details_provider.dart';
import 'visit_helpers.dart';

class CollectionStatusSection extends StatelessWidget {
  const CollectionStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final routeDetailsProvider = context.watch<RouteDetailsProviders>();
    final routeDetails = routeDetailsProvider.routeDetails;

    // Use null-aware operators to default to 0 if null
    final pendingAmount = routeDetails?.pendingAmount ?? 0.0;
    final totalCredit = routeDetails?.totalCredit ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Collection Status",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            buildCollectionCard(
              pendingAmount.toStringAsFixed(2),
              "PENDING AMOUNT",
            ),
            const SizedBox(width: 12),
            buildCollectionCard(
              totalCredit.toStringAsFixed(2),
              "TOTAL CREDIT",
            ),
          ],
        ),
      ],
    );
  }
}
