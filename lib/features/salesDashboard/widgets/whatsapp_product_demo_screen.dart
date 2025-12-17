import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

class DemoWhatsappScreen extends StatefulWidget {
  const DemoWhatsappScreen({super.key});

  @override
  State<DemoWhatsappScreen> createState() => _DemoWhatsappScreenState();
}

class _DemoWhatsappScreenState extends State<DemoWhatsappScreen> {
  final _addressController = TextEditingController();
  final _productController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? demoDate;
  DateTime? followUpDate;

  double? latitude;
  double? longitude;
  String? resolvedAddress;
  bool _isLoadingLocation = false;

  Future<void> _pickDate({required bool isDemo}) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple.shade600,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isDemo) {
          demoDate = date;
        } else {
          followUpDate = date;
        }
      });
    }
  }

  Future<void> _fetchCoordinatesAndAddress(String address) async {
    if (address.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an address'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoadingLocation = true);

    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        latitude = locations.first.latitude;
        longitude = locations.first.longitude;

        final placemarks =
        await placemarkFromCoordinates(latitude!, longitude!);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          resolvedAddress =
          '${p.name}, ${p.locality}, ${p.administrativeArea}, ${p.postalCode}, ${p.country}';
        }

        setState(() => _isLoadingLocation = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location found successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to fetch address or coordinates'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendToWhatsApp() async {
    if (latitude == null ||
        longitude == null ||
        demoDate == null ||
        followUpDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all details'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final message = '''📍 *Demo Details*

📌 *Address (Entered)*:
${_addressController.text}

📍 *Resolved Address*:
$resolvedAddress

🌐 *Coordinates*:
Latitude: $latitude
Longitude: $longitude

🧪 *Product*:
${_productController.text}

📅 *Demo Date*:
${DateFormat('dd MMM yyyy').format(demoDate!)}

📝 *Description*:
${_descriptionController.text}

📆 *Next Follow-up*:
${DateFormat('dd MMM yyyy').format(followUpDate!)}''';

    final uri = Uri.parse(
      'https://wa.me/918810508467?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('WhatsApp not installed'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration _decor(String label, {IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, color: Colors.purple.shade600)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.purple.shade600, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const AppStatusBar(),
          Material(
            elevation: 2,
            child: Container(
              color: Colors.white,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Plan Demo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Address Section
                    _buildSectionCard(
                      title: 'Location Details',
                      icon: Icons.location_on,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _addressController,
                            decoration: _decor(
                              'Demo Address',
                              icon: Icons.location_on,
                              hint: 'Enter full address',
                            ).copyWith(
                              suffixIcon: _isLoadingLocation
                                  ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.purple.shade600,
                                  ),
                                ),
                              )
                                  : IconButton(
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.teal.shade600,
                                ),
                                onPressed: () => _fetchCoordinatesAndAddress(
                                    _addressController.text),
                              ),
                            ),
                          ),
                          if (latitude != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade50,
                                    Colors.purple.shade100,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.purple.shade200,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.purple.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Location Found',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.purple.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    resolvedAddress ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.place,
                                          size: 16,
                                          color: Colors.purple.shade700,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${latitude?.toStringAsFixed(6)}, ${longitude?.toStringAsFixed(6)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Product Section
                    _buildSectionCard(
                      title: 'Product Information',
                      icon: Icons.science,
                      child: TextField(
                        controller: _productController,
                        decoration: _decor(
                          'Product Name',
                          icon: Icons.science,
                          hint: 'Enter product name',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Dates Section
                    _buildSectionCard(
                      title: 'Schedule',
                      icon: Icons.calendar_today,
                      child: Column(
                        children: [
                          _buildDateSelector(
                            label: demoDate == null
                                ? 'Select Demo Date'
                                : DateFormat('dd MMM yyyy').format(demoDate!),
                            icon: Icons.event,
                            iconColor: Colors.blue.shade600,
                            isSelected: demoDate != null,
                            onTap: () => _pickDate(isDemo: true),
                          ),
                          const SizedBox(height: 12),
                          _buildDateSelector(
                            label: followUpDate == null
                                ? 'Select Follow-up Date'
                                : DateFormat('dd MMM yyyy').format(followUpDate!),
                            icon: Icons.event_repeat,
                            iconColor: Colors.orange.shade600,
                            isSelected: followUpDate != null,
                            onTap: () => _pickDate(isDemo: false),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description Section
                    _buildSectionCard(
                      title: 'Additional Details',
                      icon: Icons.notes,
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: _decor(
                          'Description',
                          icon: Icons.notes,
                          hint: 'Add any additional notes...',
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // WhatsApp Button
                    ElevatedButton.icon(
                      icon: const Icon(FontAwesomeIcons.whatsapp, size: 24),
                      label: const Text(
                        'Send to WhatsApp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _sendToWhatsApp,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.purple.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.purple.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.grey.shade800 : Colors.grey.shade600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _productController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}