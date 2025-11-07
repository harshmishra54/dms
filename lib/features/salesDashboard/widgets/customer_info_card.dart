import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/rout_details_provider.dart';

class CustomerInfoCard extends StatefulWidget {
  const CustomerInfoCard({super.key});

  @override
  State<CustomerInfoCard> createState() => _CustomerInfoCardState();
}

class _CustomerInfoCardState extends State<CustomerInfoCard> {
  bool _calledApi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_calledApi) {
      _calledApi = true;

      /// Defer this until after the current build
      Future.microtask(() {
        Provider.of<RouteDetailsProviders>(context, listen: false).fetchRouteDetails();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RouteDetailsProviders>(context);
    final routeDetails = provider.routeDetails;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage.isNotEmpty) {
      return Center(
        child: AutoTranslateText(
          provider.errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (routeDetails == null) {
      return const Center(
        child: AutoTranslateText("Customer information not available."),
      );
    }

    return Container(
      width: 400,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoTranslateText(
            routeDetails.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            overflow: TextOverflow.ellipsis, // adds "..." if text overflows
            maxLines: 1, // limits to one line
            // softWrap: false, // prevents wrapping to the next line
          ),

          AutoTranslateText(
            routeDetails.firmName,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            // softWrap: false,
          ),

          AutoTranslateText(
            routeDetails.mobileNo,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
