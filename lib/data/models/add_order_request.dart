 // Assuming you put LineItem in a separate file

import 'package:TrustTags_DMS/data/models/line_item.dart';

class AddOrderRequest {
  final String price;
  final String schemePrice;
  final String gst;
  final int roleId;
  final int requestedRoleId;
  final int qty;
  final String createdBy;
  final String fromLocation;
  final String toLocation;
  final String expectedDate;
  final List<LineItem> lineItems;


  AddOrderRequest({
    required this.price,
    required this.schemePrice,
    required this.gst,
    required this.roleId,
    required this.requestedRoleId,
    required this.qty,
    required this.createdBy,
    required this.fromLocation,
    required this.toLocation,
    required this.expectedDate,
    required this.lineItems,
  });

  Map<String, dynamic> toJson() => {
    'price': price,
    'scheme_price': schemePrice,
    'gst': gst,
    'role_id': roleId,
    'requested_role_id': requestedRoleId,
    'qty': qty,
    'created_by': createdBy,
    'from_location': fromLocation,
    'to_location': toLocation,
    'expected_date': expectedDate,
    'lineItems': lineItems.map((item) => item.toJson()).toList(),
  };
}
