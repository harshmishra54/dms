import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/product_recommendation_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/list_farmer_details_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/product_recommendation_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/ProductDemo/provider/feedback_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/data/models/product_recommendation_request.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

class RecommendedProductsFarmerScreen extends StatefulWidget {
  final List<Recomm>? recommendations;

  const RecommendedProductsFarmerScreen({Key? key, this.recommendations})
      : super(key: key);

  @override
  State<RecommendedProductsFarmerScreen> createState() =>
      _RecommendedProductsFarmerScreenState();
}

class _RecommendedProductsFarmerScreenState
    extends State<RecommendedProductsFarmerScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();

  void _onPhoneChanged(String value, FarmerDetailsProvider provider) {
    if (value.length == 10) {
      provider.fetchFarmerDetails(value);
    } else if (value.isEmpty) {
      provider.reset();
    }
  }
  late FarmerDetailsProvider _provider;
  late FeedbackProvider _feedbackProvider;
  late ProductRecommendationProvider _recProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize providers only once
    if (!mounted) return;
    _provider = context.read<FarmerDetailsProvider>();
    _recProvider = context.read<ProductRecommendationProvider>();
    _feedbackProvider = context.read<FeedbackProvider>();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _provider.reset(); // safe now
    super.dispose();
  }

  Future<void> _pickContact() async {
    try {
      // Open native contact picker
      final Contact? contact = await _contactPicker.selectPhoneNumber();

      if (contact != null && contact.selectedPhoneNumber != null) {
        String phone = contact.selectedPhoneNumber!.replaceAll(RegExp(r'\D'), ''); // remove non-digits

        // Trim country code if present (like +91 or 91)
        if (phone.length > 10) {
          phone = phone.substring(phone.length - 10); // keep last 10 digits
        }

        _phoneController.text = phone;

        // Fetch farmer details
        _onPhoneChanged(phone, _provider);
      }
    } catch (e) {
      _showSnackBar("Failed to pick contact: $e", isError: true);
    }
  }


  Future<bool> _sendRecommendationToFarmer() async {
    final farmer = _provider.farmerDetails?.data;
    if (farmer == null) {
      _showSnackBar("Please enter a valid farmer number", isError: true);
      return false;
    }

    if ((widget.recommendations ?? []).isEmpty) {
      _showSnackBar("No recommended products to send", isError: true);
      return false;
    }

    final createdBy = await SharedPrefsHelper.getUserId();
    if (createdBy == null) {
      _showSnackBar("User not logged in", isError: true);
      return false;
    }

    // ✅ Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF8E2DE2))),
    );

    // ✅ Build Product Recommendation request
    final recRequest = ProductRecommendationRequestbody(
      farmerId: farmer.id.toString(),
      createdby: createdBy.toString(),
      recommendations: (widget.recommendations ?? []).map((r) {
        return Recommendation(
          productName: r.name,
          crop: r.crop,
          quantity: r.dosage ?? '',
          reason: r.reason,
        );
      }).toList(),
    );

    // ✅ 1️⃣ Call Product Recommendation API
    await _recProvider.recommendProducts(recRequest);

    if (_recProvider.errorMessage.isNotEmpty) {
      Navigator.of(context).pop(); // close loading
      _showSnackBar(_recProvider.errorMessage, isError: true);
      return false;
    }

    // ✅ 2️⃣ Call Feedback API using FeedbackProvider
    final message = _buildRecommendationMessage(
      _provider.farmerDetails,
      widget.recommendations ?? [],
    );

    await _feedbackProvider.sendFeedbackRequest(
      farmer.id.toString(),
      message,
    );


    if (_feedbackProvider.errorMessage != null) {
      Navigator.of(context).pop(); // close loading
      _showSnackBar(_feedbackProvider.errorMessage!, isError: true);
      return false;
    }

    Navigator.of(context).pop(); // close loading
    _showSnackBar("Recommendation and feedback sent successfully!");
    return true;
  }
  String _buildRecommendationMessage(
      dynamic farmerDetails,
      List<Recomm> recs,
      ) {
    final nearest = farmerDetails.data?.nearestRetailer;

    String productList = "";
    for (int i = 0; i < recs.length; i++) {
      final r = recs[i];
      productList +=
      "${i + 1}️⃣ ${r.name}\n\n"
          "Crop: ${r.crop}\n\n"
          "Problem: ${r.disease}\n\n"
          "Dosage: ${r.dosage ?? 'N/A'}\n\n";
    }

    return """
👩‍🌾 Hello ${farmerDetails.data?.name ?? 'Farmer'}!
Your crop needs care — and we’ve picked the best solutions to help you protect your crop and boost its growth! ✨

🌿 Recommended Products for You:

$productList
🏬 Buy these products from your nearest retailer:
Retailer: ${nearest?.name ?? 'N/A'}
📞 Phone: ${nearest?.phone ?? 'N/A'}
📍 Distance: ${nearest?.distanceKm?.toStringAsFixed(2) ?? '0'} km away

🚜 Act now to save your crop and secure a healthy harvest! 🌾
""";
  }





  @override
  Widget build(BuildContext context) {
    final recs = widget.recommendations ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<FarmerDetailsProvider>(
        builder: (context, provider, _) {
          final farmerDetails = provider.farmerDetails;

          return Column(
            children: [
              /// ✅ App Status Bar
              const AppStatusBar(),

              /// ✅ Custom Top Bar
              Material(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.08),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: AutoTranslateText(
                          'Recommended Products',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2D3748),
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),

              /// ✅ Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📱 Mobile number input
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _phoneController,
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: "Enter Farmer Mobile No",
                              labelStyle: const TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 14,
                              ),
                              counterText: "",
                              prefixIcon: const Icon(
                                Icons.phone_android,
                                color: Color(0xFF8E2DE2),
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Clear icon
                                  if (_phoneController.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () {
                                        _phoneController.clear();
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          provider.reset(); // safe now
                                        });
                                      },

                                    ),
                                  // Contacts icon
                                  IconButton(
                                    icon: const Icon(Icons.contacts, size: 20, color: Color(0xFF8E2DE2)),
                                    onPressed: _pickContact,
                                  ),
                                ],
                              ),

                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: const Color(0xFF8E2DE2).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8E2DE2),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                              _onPhoneChanged(value, provider);
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 👨‍🌾 Farmer & Retailer Info
                        if (provider.isLoading)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              child: const CircularProgressIndicator(
                                color: Color(0xFF8E2DE2),
                              ),
                            ),
                          ),

                        if (provider.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AutoTranslateText(
                                    provider.errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (farmerDetails != null) ...[
                          _buildFarmerInfo(farmerDetails),
                          const SizedBox(height: 24),
                        ],

                        // 🧾 Product recommendations header
                        // ✅ Recommended Products Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_bag,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: AutoTranslateText(
                                "Recommended Products",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

// ✅ Recommended Products List or Empty State
                        if (recs.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Color(0xFFCBD5E0),
                                  ),
                                  SizedBox(height: 16),
                                  AutoTranslateText(
                                    "No recommended products available.",
                                    style: TextStyle(
                                      color: Color(0xFF718096),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: recs
                                .map(
                                  (rec) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildProductCard(rec, recs.indexOf(rec)),
                              ),
                            )
                                .toList(),
                          ),


                        const SizedBox(height: 10),

                        // 💬 WhatsApp Button
                        const SizedBox(height: 10),

// 💬 WhatsApp Button
                        if (farmerDetails != null && recs.isNotEmpty)
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.topBarColor, // change to your desired color
                                  foregroundColor: Colors.white,  // text color
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const AutoTranslateText("Send Recommendation"),
                                onPressed: () async {
                                  final success = await _sendRecommendationToFarmer();
                                  if (success) {
                                    _showSnackBar("Recommendation sent successfully");
                                  }
                                },
                              ),




                            ),
                          ),


                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🧾 Send WhatsApp message
  /// 🧾 Send WhatsApp message in the detailed format you want
  void _sendWhatsAppMessage(
      String phone, dynamic farmerDetails, List<Recomm> recs) async {
    final nearest = farmerDetails.data?.nearestRetailer;

    // Build the detailed product list using only available fields
    String productList = "";
    for (int i = 0; i < recs.length; i++) {
      final r = recs[i];
      productList +=
      "${i + 1}️⃣ ${r.name}\n\n"
          "Crop: ${r.crop}\n\n"
          "Problem: ${r.disease}\n\n"
          "Dosage: ${r.dosage ?? 'N/A'}\n\n";
    }

    final msg = Uri.encodeComponent("""
👩‍🌾 Hello ${farmerDetails.data?.name ?? 'Farmer'}!
Your crop needs care — and we’ve picked the best solutions to help you protect your Crop and boost their growth! ✨

🌿 Recommended Products for You:

$productList
🏬 Buy these products from your nearest retailer:
Retailer: ${nearest?.name ?? 'N/A'}
📞 Phone: ${nearest?.phone ?? 'N/A'}
📍 Distance: ${nearest?.distanceKm?.toStringAsFixed(2) ?? '0'} km away

🚜 Act now to save your crop and secure a healthy harvest! Contact ${nearest?.name ?? 'retailer'} today to check availability and get your products on time. 🌾
""");

    final url = "https://wa.me/91$phone?text=$msg";
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar("Could not open WhatsApp", isError: true);
      }
    } catch (e) {
      _showSnackBar("Error opening WhatsApp: $e", isError: true);
    }
  }

  /// Show SnackBar helper
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: AutoTranslateText(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF25D366),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 👨‍🌾 Farmer + Retailer Info card
  Widget _buildFarmerInfo(farmer) {
    final nearest = farmer.data?.nearestRetailer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8E2DE2).withOpacity(0.05),
            const Color(0xFF4A00E0).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8E2DE2).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AutoTranslateText(
                      "Farmer Details",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 2),
                    AutoTranslateText(
                      farmer.data?.name ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 18, color: Color(0xFF8E2DE2)),
              const SizedBox(width: 8),
              AutoTranslateText(
                farmer.data?.phone ?? 'N/A',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (nearest != null) ...[
            const SizedBox(height: 6),
            const Divider(height: 1),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A00E0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Color(0xFF4A00E0),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const AutoTranslateText(
                  "Nearest Retailer",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A00E0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.business, "Name", nearest.name ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone_android, "Phone", nearest.phone ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.location_on,
              "Distance",
              "${nearest.distanceKm?.toStringAsFixed(2) ?? '0'} km",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF718096)),
        const SizedBox(width: 8),
        AutoTranslateText(
          "$label: ",
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: AutoTranslateText(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 🧾 Product Card
  Widget _buildProductCard(Recomm rec, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8E2DE2).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8E2DE2).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: rec.image != null && rec.image!.isNotEmpty
                    ? Image.network(
                  rec.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                )
                    : _buildPlaceholderImage(),
              ),
            ),
            const SizedBox(width: 16),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoTranslateText(
                    rec.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (rec.crop.isNotEmpty)
                    _buildDetailChip(Icons.grass, rec.crop),
                  if (rec.disease.isNotEmpty)
                    _buildDetailChip(Icons.bug_report, rec.disease),
                  if (rec.dosage != null && rec.dosage!.isNotEmpty)
                    _buildDetailChip(Icons.medication, rec.dosage!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.shopping_bag,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF8E2DE2)),
          const SizedBox(width: 6),
          Expanded(
            child: AutoTranslateText(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5568),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
