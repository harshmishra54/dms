import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @session_expired.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get session_expired;

  /// No description provided for @please_login_again.
  ///
  /// In en, this message translates to:
  /// **'Please login again.'**
  String get please_login_again;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @you_need_needed_more_points_to_claim_reward_name.
  ///
  /// In en, this message translates to:
  /// **'You need {needed} more points to claim {rewardName}.'**
  String you_need_needed_more_points_to_claim_reward_name(Object needed, Object rewardName);

  /// No description provided for @reward_reward_name_claimed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Reward {rewardName} claimed successfully!'**
  String reward_reward_name_claimed_successfully(Object rewardName);

  /// No description provided for @exit_app.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exit_app;

  /// No description provided for @do_you_want_to_exit_the_app.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit the app?'**
  String get do_you_want_to_exit_the_app;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logging_out.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get logging_out;

  /// No description provided for @are_you_sure_you_want_to_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get are_you_sure_you_want_to_logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @no_history_found.
  ///
  /// In en, this message translates to:
  /// **'No history found.'**
  String get no_history_found;

  /// No description provided for @no_scheme_data_found.
  ///
  /// In en, this message translates to:
  /// **'No scheme data found.'**
  String get no_scheme_data_found;

  /// No description provided for @fill_all_required_details.
  ///
  /// In en, this message translates to:
  /// **'Fill all required details.'**
  String get fill_all_required_details;

  /// No description provided for @failed_provider_errormessage.
  ///
  /// In en, this message translates to:
  /// **'Failed: {errorMessage}'**
  String failed_provider_errormessage(Object errorMessage);

  /// No description provided for @fill_all_details.
  ///
  /// In en, this message translates to:
  /// **'Fill all details.'**
  String get fill_all_details;

  /// No description provided for @error_e.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error_e(Object error);

  /// No description provided for @user_token_not_found.
  ///
  /// In en, this message translates to:
  /// **'User token not found.'**
  String get user_token_not_found;

  /// No description provided for @enter_a_valid_pincode_to_auto_fill_state_district.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid pincode to auto-fill state/district.'**
  String get enter_a_valid_pincode_to_auto_fill_state_district;

  /// No description provided for @failed_to_update_profile_profileprovider_errormessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {errorMessage}'**
  String failed_to_update_profile_profileprovider_errormessage(Object errorMessage);

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @failed_to_load_dashboard_data.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard data.'**
  String get failed_to_load_dashboard_data;

  /// No description provided for @confirm_logout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirm_logout;

  /// No description provided for @are_you_sure_you_want_to_log_out.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get are_you_sure_you_want_to_log_out;

  /// No description provided for @yes_logout.
  ///
  /// In en, this message translates to:
  /// **'Yes, Logout'**
  String get yes_logout;

  /// No description provided for @reward_rejected.
  ///
  /// In en, this message translates to:
  /// **'Reward Rejected'**
  String get reward_rejected;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @reward_approved.
  ///
  /// In en, this message translates to:
  /// **'Reward Approved'**
  String get reward_approved;

  /// No description provided for @no_reward_claim_history_found.
  ///
  /// In en, this message translates to:
  /// **'No reward claim history found.'**
  String get no_reward_claim_history_found;

  /// No description provided for @choose_file.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get choose_file;

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirm_delete;

  /// No description provided for @are_you_sure_you_want_to_delete_uniquecode.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {uniqueCode}?'**
  String are_you_sure_you_want_to_delete_uniquecode(Object uniqueCode);

  /// No description provided for @deleted_uniquecode.
  ///
  /// In en, this message translates to:
  /// **'Deleted {uniqueCode}'**
  String deleted_uniquecode(Object uniqueCode);

  /// No description provided for @credit_limit_request_submitted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Credit limit request submitted successfully.'**
  String get credit_limit_request_submitted_successfully;

  /// No description provided for @base_price_item_price.
  ///
  /// In en, this message translates to:
  /// **'Base Price: ₹{price}'**
  String base_price_item_price(Object price);

  /// No description provided for @totalprice_tostringasfixed_2.
  ///
  /// In en, this message translates to:
  /// **'₹{totalPrice}'**
  String totalprice_tostringasfixed_2(Object totalPrice);

  /// No description provided for @gst_tostringasfixed_2.
  ///
  /// In en, this message translates to:
  /// **'₹{gst}'**
  String gst_tostringasfixed_2(Object gst);

  /// No description provided for @discount_tostringasfixed_2.
  ///
  /// In en, this message translates to:
  /// **'₹{discount}'**
  String discount_tostringasfixed_2(Object discount);

  /// No description provided for @please_select_distributor_and_add_at_least_one_product.
  ///
  /// In en, this message translates to:
  /// **'Please select distributor and add at least one product.'**
  String get please_select_distributor_and_add_at_least_one_product;

  /// No description provided for @please_select_an_expected_date.
  ///
  /// In en, this message translates to:
  /// **'Please select an expected date.'**
  String get please_select_an_expected_date;

  /// No description provided for @credit_limit_exceeded.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit Exceeded'**
  String get credit_limit_exceeded;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @order_placed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully.'**
  String get order_placed_successfully;

  /// No description provided for @no_products_available.
  ///
  /// In en, this message translates to:
  /// **'No products available.'**
  String get no_products_available;

  /// No description provided for @raise_dispute.
  ///
  /// In en, this message translates to:
  /// **'Raise Dispute'**
  String get raise_dispute;

  /// No description provided for @please_enter_a_reason_for_cancelling_this_order.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason for cancelling this order:'**
  String get please_enter_a_reason_for_cancelling_this_order;

  /// No description provided for @reason_cannot_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Reason cannot be empty.'**
  String get reason_cannot_be_empty;

  /// No description provided for @order_cancelled_successfully.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully.'**
  String get order_cancelled_successfully;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @confirm_order.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirm_order;

  /// No description provided for @are_you_sure_you_want_to_displaytext_this_order.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to {displayText} this order?'**
  String are_you_sure_you_want_to_displaytext_this_order(Object displayText);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'PARTIAL'**
  String get partial;

  /// No description provided for @no_orders_found.
  ///
  /// In en, this message translates to:
  /// **'No orders found.'**
  String get no_orders_found;

  /// No description provided for @please_enter_a_valid_36_digit_uid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 36-digit UID.'**
  String get please_enter_a_valid_36_digit_uid;

  /// No description provided for @invalid_or_unsupported_pin_code.
  ///
  /// In en, this message translates to:
  /// **'Invalid or unsupported PIN code.'**
  String get invalid_or_unsupported_pin_code;

  /// No description provided for @profile_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated Successfully.'**
  String get profile_updated_successfully;

  /// No description provided for @please_enter_a_valid_10_digit_mobile_number_and_fill_all_required_fields.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number and fill all required fields.'**
  String get please_enter_a_valid_10_digit_mobile_number_and_fill_all_required_fields;

  /// No description provided for @farmer_registered_successfully.
  ///
  /// In en, this message translates to:
  /// **'Farmer registered successfully.'**
  String get farmer_registered_successfully;

  /// No description provided for @location_services_are_disabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get location_services_are_disabled;

  /// No description provided for @location_permissions_are_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied.'**
  String get location_permissions_are_denied;

  /// No description provided for @please_select_at_least_one_product_and_enter_a_query.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one product and enter a query.'**
  String get please_select_at_least_one_product_and_enter_a_query;

  /// No description provided for @user_id_not_found_please_login_again.
  ///
  /// In en, this message translates to:
  /// **'User ID not found. Please login again.'**
  String get user_id_not_found_please_login_again;

  /// No description provided for @product_already_added.
  ///
  /// In en, this message translates to:
  /// **'Product already added.'**
  String get product_already_added;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @no_farmers_found.
  ///
  /// In en, this message translates to:
  /// **'No farmers found.'**
  String get no_farmers_found;

  /// No description provided for @clear_search.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clear_search;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @select_all.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get select_all;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
