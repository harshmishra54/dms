import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/product_price_provider.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/data/models/product_price_model.dart';

class AddProductPriceScreen extends StatefulWidget {
  const AddProductPriceScreen({super.key});

  @override
  State<AddProductPriceScreen> createState() => _AddProductPriceScreenState();
}

class _AddProductPriceScreenState extends State<AddProductPriceScreen> {
  List<ProductPrice> _productList = [];
  bool _isFileSelected = false;
  bool _isProcessing = false;
  List<int> _invalidRows = [];
  List<String> _missingProducts = [];

  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isProcessing = true);

      try {
        final provider = Provider.of<AddProductPriceProvider>(context, listen: false);
        final serverProducts = provider.serverProductList;
        final serverProductCodes = serverProducts.map((p) => p.itemCode).toList();

        // Use compute for heavy processing (better than manual isolate)
        final parseResult = await compute(
          _parseExcelWorker,
          {
            'filePath': result.files.single.path!,
            'serverProductCodes': serverProductCodes,
          },
        );

        if (!mounted) return;

        // Check for errors
        if (parseResult['error'] != null) {
          throw Exception(parseResult['error']);
        }

        // Convert JSON back to ProductPrice objects
        final products = (parseResult['products'] as List)
            .map((json) => ProductPrice(
          itemCode: json['itemCode'],
          productName: json['productName'],
          uniqueName: json['uniqueName'],
          price: json['price'],
          schemePrice: json['schemePrice'],
        ))
            .toList();

        setState(() {
          _productList = products;
          _isFileSelected = true;
          _invalidRows = List<int>.from(parseResult['invalidRows'] ?? []);
          _missingProducts = List<String>.from(parseResult['missingProducts'] ?? []);
          _isProcessing = false;
        });

        if (_invalidRows.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoTranslateText("⚠️ Invalid rows: ${_invalidRows.take(10).join(', ')}${_invalidRows.length > 10 ? ' and ${_invalidRows.length - 10} more' : ''}"),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }

        if (_missingProducts.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoTranslateText("⚠️ ${_missingProducts.length} product(s) missing from file."),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AutoTranslateText("❌ Error processing file: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } else {
      setState(() => _isFileSelected = false);
    }
  }

  // Static method to run in isolate - must be top-level or static
  static Map<String, dynamic> _parseExcelWorker(Map<String, dynamic> params) {
    try {
      final filePath = params['filePath'] as String;
      final serverProductCodes = List<String>.from(params['serverProductCodes']);
      final serverProductSet = serverProductCodes.toSet();

      // Read file
      final file = File(filePath);
      final fileBytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(fileBytes);

      List<Map<String, dynamic>> productJsonList = [];
      List<int> invalidRows = [];
      Set<String> fileProductCodes = {};

      // Get first sheet
      if (excel.tables.isEmpty) {
        return {
          'error': 'No sheets found in Excel file',
          'products': [],
          'invalidRows': [],
          'missingProducts': [],
        };
      }

      final firstTableName = excel.tables.keys.first;
      final rows = excel.tables[firstTableName]?.rows ?? [];

      if (rows.isEmpty || rows.length < 2) {
        return {
          'error': 'Excel file is empty or has only headers',
          'products': [],
          'invalidRows': [],
          'missingProducts': [],
        };
      }

      // Process rows (skip header row at index 0)
      for (int i = 1; i < rows.length; i++) {
        var row = rows[i];

        // Check if row has minimum required columns
        if (row.isEmpty || row.length < 4) {
          invalidRows.add(i + 1);
          continue;
        }

        // Check if all cells in row are null (empty row)
        bool isEmptyRow = row.every((cell) => cell?.value == null);
        if (isEmptyRow) {
          continue; // Skip empty rows silently
        }

        String itemCode = row[0]?.value?.toString().trim() ?? "";
        String productName = row[1]?.value?.toString().trim() ?? "";
        String uniqueName = (row.length > 2) ? (row[2]?.value?.toString().trim() ?? "") : "";
        double? price = double.tryParse(row[3]?.value?.toString() ?? "");
        double? schemePrice = (row.length > 4) ? double.tryParse(row[4]?.value?.toString() ?? "") : null;

        // Validate required fields
        if (itemCode.isEmpty || productName.isEmpty || price == null) {
          invalidRows.add(i + 1);
          continue;
        }

        // Add to list as JSON (serializable)
        productJsonList.add({
          'itemCode': itemCode,
          'productName': productName,
          'uniqueName': uniqueName,
          'price': price,
          'schemePrice': schemePrice ?? 0.0,
        });
        fileProductCodes.add(itemCode);
      }

      // Find missing products
      List<String> missingProducts = serverProductSet.difference(fileProductCodes).toList();

      return {
        'products': productJsonList,
        'invalidRows': invalidRows,
        'missingProducts': missingProducts,
        'error': null,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'products': [],
        'invalidRows': [],
        'missingProducts': [],
      };
    }
  }

  Future<void> _uploadProducts() async {
    if (_productList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoTranslateText("Please select a valid Excel file."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<AddProductPriceProvider>(context, listen: false);
    await provider.addProductPrice(_productList);

    if (!mounted) return;

    if (provider.updateResponse != null && provider.updateResponse!.success == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoTranslateText("✅ ${provider.updateResponse!.message}"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _productList.clear();
        _isFileSelected = false;
        _invalidRows.clear();
        _missingProducts.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoTranslateText("❌ ${provider.errorMessage ?? 'Upload failed.'}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddProductPriceProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          const AppStatusBar(),
          _buildHeaderBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUploadCard(),
                  const SizedBox(height: 24),

                  if (_isProcessing)
                    _buildProcessingCard(),

                  if (_isFileSelected && !_isProcessing)
                    _buildStatusCard(
                      "File Loaded Successfully",
                      "${_productList.length} products ready to upload",
                      Colors.deepPurple,
                      Icons.check_circle_outline,
                    ),

                  if (_invalidRows.isNotEmpty)
                    _buildWarningCard(
                      icon: Icons.error_outline,
                      title: "Invalid Rows Detected",
                      message: "Rows: ${_invalidRows.take(10).join(', ')}${_invalidRows.length > 10 ? ' and ${_invalidRows.length - 10} more' : ''}",
                      color: Colors.orange,
                    ),

                  if (_missingProducts.isNotEmpty)
                    _buildWarningCard(
                      icon: Icons.info_outline,
                      title: "Missing Products",
                      message: "${_missingProducts.length} products missing: ${_missingProducts.take(5).join(', ')}${_missingProducts.length > 5 ? ' and ${_missingProducts.length - 5} more' : ''}",
                      color: Colors.deepPurple,
                    ),

                  if (_isFileSelected && !_isProcessing) ...[
                    const SizedBox(height: 16),
                    _buildUploadButton(provider),
                  ],

                  const SizedBox(height: 24),
                  _buildHelpSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI Builders ----------

  Widget _buildHeaderBar(BuildContext context) => Material(
    elevation: 4,
    shadowColor: Colors.black.withOpacity(0.1),
    child: Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: AutoTranslateText(
              'Add Price',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 18),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    ),
  );

  Widget _buildUploadCard() => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0AAFF), Color(0xFFC77DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_outlined,
                size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          AutoTranslateText(
            "Upload Excel File",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          AutoTranslateText(
            "Select an Excel file containing product prices",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _pickExcelFile,
            icon: const Icon(Icons.folder_open),
            label: const AutoTranslateText("Choose File"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.topBarColor,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildProcessingCard() => Card(
    elevation: 2,
    color: Colors.blue[50],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.blue[200]!, width: 1),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          AutoTranslateText(
            "Processing file...",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 8),
          AutoTranslateText(
            "This may take up to 30 seconds for large files",
            style: TextStyle(fontSize: 14, color: Colors.blue[700]),
          ),
        ],
      ),
    ),
  );

  Widget _buildStatusCard(
      String title, String subtitle, MaterialColor color, IconData icon) =>
      Card(
        elevation: 2,
        color: color[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color[200]!, width: 1),
        ),
        child: ListTile(
          leading: Icon(icon, color: color[700], size: 30),
          title: AutoTranslateText(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color[900])),
          subtitle: AutoTranslateText(subtitle,
              style: TextStyle(fontSize: 14, color: color[700])),
        ),
      );

  Widget _buildWarningCard({
    required IconData icon,
    required String title,
    required String message,
    required MaterialColor color,
  }) {
    return Card(
      elevation: 2,
      color: color[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color[700], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoTranslateText(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: color[900])),
                  const SizedBox(height: 4),
                  AutoTranslateText(
                    message,
                    style: TextStyle(fontSize: 12, color: color[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(AddProductPriceProvider provider) => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton.icon(
        onPressed: provider.isLoading ? null : _uploadProducts,
        icon: provider.isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(Icons.backup),
        label: AutoTranslateText(
          provider.isLoading ? "Uploading..." : "Upload to Server",
          style:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.topBarColor,
          foregroundColor: Colors.white,
          padding:
          const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
    ),
  );

  Widget _buildHelpSection() => Card(
    elevation: 1,
    color: const Color(0xFFF3E5F5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF7B2CBF), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AutoTranslateText(
                  "File Requirements",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF4A148C),
                  ),
                ),
                const SizedBox(height: 8),
                AutoTranslateText(
                  "• Supported formats: .xlsx, .xls\n"
                      "• Required columns: Item Code, Product Name, Price\n"
                      "• Optional: Unique Name, Scheme Price\n"
                      "• File should be smaller in size.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}