import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/credit_limit_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/credit_update_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Expense/amount_limit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/credit_update_model.dart';

class CreditLimitUpdateScreen extends StatefulWidget {
  final String? distributorId;
  const CreditLimitUpdateScreen({super.key, this.distributorId});

  @override
  State<CreditLimitUpdateScreen> createState() =>
      _CreditLimitUpdateScreenState();
}

class _CreditLimitUpdateScreenState extends State<CreditLimitUpdateScreen> {
  final TextEditingController _currentLimitController = TextEditingController();
  final TextEditingController _newLimitController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final roleId= await SharedPrefsHelper.getRoleId();
      if (roleId!= 1){
        final creditProvider =
        Provider.of<CreditLimitProvider>(context, listen: false);
        await creditProvider.fetchCreditLimitList(roleId: "1",requestId: widget.distributorId??"");

        final currentLimit = (creditProvider.creditList.isNotEmpty &&
            creditProvider.creditList.first.currentLimit != null &&
            creditProvider.creditList.first.currentLimit != 0)
            ? creditProvider.creditList.first.currentLimit
            : 0;

        _currentLimitController.text = currentLimit.toString();
        setState(() {});
      }
      else{
        final userId=await SharedPrefsHelper.getUserId();
      final creditProvider =
      Provider.of<CreditLimitProvider>(context, listen: false);
      await creditProvider.fetchCreditLimitList(roleId: "1",requestId: userId??"");

      final currentLimit = (creditProvider.creditList.isNotEmpty &&
          creditProvider.creditList.first.currentLimit != null &&
          creditProvider.creditList.first.currentLimit != 0)
          ? creditProvider.creditList.first.currentLimit
          : 0;

      _currentLimitController.text = currentLimit.toString();
      setState(() {});
    }});
  }

  @override
  void dispose() {
    _currentLimitController.dispose();
    _newLimitController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CreditUpdateProvider()),
        ChangeNotifierProvider(create: (_) => CreditLimitProvider()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF5FF),
        body: Consumer2<CreditUpdateProvider, CreditLimitProvider>(
          builder: (context, updateProvider, limitProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppStatusBar(),
                Material(
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
                            'Credit Limit Update',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: limitProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AutoTranslateText(
                          'Your Current Credit Limit',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ✅ Full-width current limit display
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(
                            _currentLimitController.text,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const AutoTranslateText(
                          'Enter New Limit',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInputField(
                          controller: _newLimitController,
                          hintText: 'Enter Limit',
                          inputType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            MaxAmountInputFormatter(1000000000000000),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const AutoTranslateText(
                          'Enter Reason',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInputField(
                          controller: _reasonController,
                          hintText: 'Enter Reason',
                          maxLength: 30
                        ),
                        const SizedBox(height: 20),
                        if (updateProvider.responseMessage.isNotEmpty)
                          AutoTranslateText(
                            updateProvider.responseMessage,
                            style: TextStyle(
                              color: updateProvider.responseMessage
                                  .contains('Failed')
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: updateProvider.isLoading
                                ? null
                                : () async {
                              final newLimit = double.tryParse(
                                  _newLimitController.text.trim());
                              if (newLimit == null ||
                                  newLimit <= 0) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                    content: AutoTranslateText(
                                        'Please enter a valid new limit')));
                                return;
                              }

                              final currentLimit =
                                  double.tryParse(
                                      _currentLimitController
                                          .text
                                          .trim()) ??
                                      0;

                              final savedRoleId = await SharedPrefsHelper.getRoleId() ?? "";
                              final savedUserId = await SharedPrefsHelper.getUserId();

                              final requestId = savedRoleId == 1
                                  ? savedUserId
                                  : widget.distributorId;

                              print("ROLE ID = $savedRoleId");
                              print("USER ID = $savedUserId");
                              print("WIDGET DISTRIBUTOR ID = ${widget.distributorId}");
                              print("FINAL REQUEST ID = $requestId");

                              if (requestId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: AutoTranslateText('Request ID not found'),
                                  ),
                                );
                                return;
                              }



                              final request = CreditUpdateRequest(
                                roleId: "1",
                                requestId: requestId,
                                requestedLimit: newLimit,
                                reason: _reasonController.text.trim(),
                                current_limit: currentLimit,
                              );


                              final success = await updateProvider
                                  .submitCreditLimit(
                                  request: request);

                              if (success) {
                                Navigator.pop(context, true);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                    content: AutoTranslateText(updateProvider
                                        .responseMessage)));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA259FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: updateProvider.isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const AutoTranslateText(
                              'Add Request',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: [
        if (inputFormatters != null) ...inputFormatters,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
