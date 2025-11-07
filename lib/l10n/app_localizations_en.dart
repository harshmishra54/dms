// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get session_expired => 'Session Expired';

  @override
  String get please_login_again => 'Please login again.';

  @override
  String get ok => 'OK';

  @override
  String you_need_needed_more_points_to_claim_reward_name(Object needed, Object rewardName) {
    return 'You need $needed more points to claim $rewardName.';
  }

  @override
  String reward_reward_name_claimed_successfully(Object rewardName) {
    return 'Reward $rewardName claimed successfully!';
  }

  @override
  String get exit_app => 'Exit App';

  @override
  String get do_you_want_to_exit_the_app => 'Do you want to exit the app?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get logout => 'Logout';

  @override
  String get logging_out => 'Logging out...';

  @override
  String get are_you_sure_you_want_to_logout => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get no_history_found => 'No history found.';

  @override
  String get no_scheme_data_found => 'No scheme data found.';

  @override
  String get fill_all_required_details => 'Fill all required details.';

  @override
  String failed_provider_errormessage(Object errorMessage) {
    return 'Failed: $errorMessage';
  }

  @override
  String get fill_all_details => 'Fill all details.';

  @override
  String error_e(Object error) {
    return 'Error: $error';
  }

  @override
  String get user_token_not_found => 'User token not found.';

  @override
  String get enter_a_valid_pincode_to_auto_fill_state_district => 'Enter a valid pincode to auto-fill state/district.';

  @override
  String failed_to_update_profile_profileprovider_errormessage(Object errorMessage) {
    return 'Failed to update profile: $errorMessage';
  }

  @override
  String get next => 'Next';

  @override
  String get failed_to_load_dashboard_data => 'Failed to load dashboard data.';

  @override
  String get confirm_logout => 'Confirm Logout';

  @override
  String get are_you_sure_you_want_to_log_out => 'Are you sure you want to log out?';

  @override
  String get yes_logout => 'Yes, Logout';

  @override
  String get reward_rejected => 'Reward Rejected';

  @override
  String get close => 'Close';

  @override
  String get reward_approved => 'Reward Approved';

  @override
  String get no_reward_claim_history_found => 'No reward claim history found.';

  @override
  String get choose_file => 'Choose File';

  @override
  String get confirm_delete => 'Confirm Delete';

  @override
  String are_you_sure_you_want_to_delete_uniquecode(Object uniqueCode) {
    return 'Are you sure you want to delete $uniqueCode?';
  }

  @override
  String deleted_uniquecode(Object uniqueCode) {
    return 'Deleted $uniqueCode';
  }

  @override
  String get credit_limit_request_submitted_successfully => 'Credit limit request submitted successfully.';

  @override
  String base_price_item_price(Object price) {
    return 'Base Price: ₹$price';
  }

  @override
  String totalprice_tostringasfixed_2(Object totalPrice) {
    return '₹$totalPrice';
  }

  @override
  String gst_tostringasfixed_2(Object gst) {
    return '₹$gst';
  }

  @override
  String discount_tostringasfixed_2(Object discount) {
    return '₹$discount';
  }

  @override
  String get please_select_distributor_and_add_at_least_one_product => 'Please select distributor and add at least one product.';

  @override
  String get please_select_an_expected_date => 'Please select an expected date.';

  @override
  String get credit_limit_exceeded => 'Credit Limit Exceeded';

  @override
  String get proceed => 'Proceed';

  @override
  String get order_placed_successfully => 'Order placed successfully.';

  @override
  String get no_products_available => 'No products available.';

  @override
  String get raise_dispute => 'Raise Dispute';

  @override
  String get please_enter_a_reason_for_cancelling_this_order => 'Please enter a reason for cancelling this order:';

  @override
  String get reason_cannot_be_empty => 'Reason cannot be empty.';

  @override
  String get order_cancelled_successfully => 'Order cancelled successfully.';

  @override
  String get submit => 'Submit';

  @override
  String get confirm_order => 'Confirm Order';

  @override
  String are_you_sure_you_want_to_displaytext_this_order(Object displayText) {
    return 'Are you sure you want to $displayText this order?';
  }

  @override
  String get accept => 'ACCEPT';

  @override
  String get reject => 'Reject';

  @override
  String get partial => 'PARTIAL';

  @override
  String get no_orders_found => 'No orders found.';

  @override
  String get please_enter_a_valid_36_digit_uid => 'Please enter a valid 36-digit UID.';

  @override
  String get invalid_or_unsupported_pin_code => 'Invalid or unsupported PIN code.';

  @override
  String get profile_updated_successfully => 'Profile Updated Successfully.';

  @override
  String get please_enter_a_valid_10_digit_mobile_number_and_fill_all_required_fields => 'Please enter a valid 10-digit mobile number and fill all required fields.';

  @override
  String get farmer_registered_successfully => 'Farmer registered successfully.';

  @override
  String get location_services_are_disabled => 'Location services are disabled.';

  @override
  String get location_permissions_are_denied => 'Location permissions are denied.';

  @override
  String get please_select_at_least_one_product_and_enter_a_query => 'Please select at least one product and enter a query.';

  @override
  String get user_id_not_found_please_login_again => 'User ID not found. Please login again.';

  @override
  String get product_already_added => 'Product already added.';

  @override
  String get retry => 'Retry';

  @override
  String get capture => 'Capture';

  @override
  String get no_farmers_found => 'No farmers found.';

  @override
  String get clear_search => 'Clear search';

  @override
  String get confirm => 'Confirm';

  @override
  String get approve => 'Approve';

  @override
  String get edit => 'Edit';

  @override
  String get select_all => 'Select All';
}
