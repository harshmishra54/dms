import 'dart:convert';
import 'dart:io';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/authentication/provider/rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Expense/amount_limit.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/expense_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/expenselist_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';
import '../../../common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/data/models/expense_req_res_model.dart';
import 'package:intl/intl.dart';


class ExpensesDetailScreen extends StatefulWidget {
  const ExpensesDetailScreen({super.key});

  @override
  State<ExpensesDetailScreen> createState() => _ExpensesDetailScreenState();
}

class _ExpensesDetailScreenState extends State<ExpensesDetailScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedExpenseType;
  final List<String> expenseTypes = ["Travel", "Food", "Stationery", "Other"];

  @override
  void initState() {
    super.initState();
    _loadRoutes(); // ✅ call async function without await
    final expenseListProvider = Provider.of<ExpenseListProvider>(context, listen: false);
    expenseListProvider.fetchExpenses();
  }

  Future<void> _loadRoutes() async {
    final routProvider = Provider.of<RoutProvider>(context, listen: false);
    final token = await SharedPrefsHelper.getAccessToken();
    final userId = await SharedPrefsHelper.getUserId();
    routProvider.loadRoutes(token ?? "", userId ?? "");
  }

  void _openAddExpensePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          const AppStatusBar(),
          _buildAppBar(),
          Expanded(
            child: Consumer<ExpenseListProvider>(
              builder: (context, expenseListProvider, _) {
                if (expenseListProvider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (expenseListProvider.error != null) {
                  return Center(
                    child: AutoTranslateText(
                      expenseListProvider.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }

                if (expenseListProvider.expenses.isEmpty) {
                  return const Center(
                    child: AutoTranslateText(
                      "No expenses found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: expenseListProvider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseListProvider.expenses[index];
                    final formattedDate = DateFormat('dd-MM-yyyy')
                        .format(DateTime.parse(expense.date));

                    Color statusColor;
                    switch (expense.isStatus.toLowerCase()) {
                      case 'approved':
                        statusColor = Colors.green;
                        break;
                      case 'pending':
                        statusColor = Colors.amber;
                        break;
                      case 'rejected':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    return _buildExpenseTile(
                      expense.reason,
                      "₹${expense.expenseCost.toStringAsFixed(2)}",
                      expense.isStatus,
                      formattedDate,
                      statusColor,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpensePage,
        backgroundColor: AppColors.topBarColor,
        child: const Icon(Icons.add),
      ),
    );

  }
  // ------------------ Widgets ------------------
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: 56,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: AutoTranslateText(
              'Expenses Detail',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
  // Expense Tile
  static Widget _buildExpenseTile(
      String title,
      String amount,
      String status,
      String date,
      Color statusColor,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoTranslateText(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Right
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AutoTranslateText(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              AutoTranslateText(
                date,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }
}
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedExpenseType;
  final List<String> expenseTypes = ["Travel", "Food", "Stationery", "Other"];

  String? _selectedRouteId;
  DateTime? _selectedDate;
  String? _pickedFileBase64;
  String? _pickedFileName;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final routProvider = Provider.of<RoutProvider>(context, listen: false);
    final token = await SharedPrefsHelper.getAccessToken();
    final userId = await SharedPrefsHelper.getUserId();
    routProvider.loadRoutes(token ?? "", userId ?? "");
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedFileBase64 = base64Encode(bytes);
        _pickedFileName = result.files.single.name;
      });
    }
  }

  void _resetForm() {
    _reasonController.clear();
    _amountController.clear();
    setState(() {
      _selectedExpenseType = null;
      _selectedDate = null;
      _pickedFileBase64 = null;
      _pickedFileName = null;
      _selectedRouteId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Consumer2<ExpenseProvider, RoutProvider>(
        builder: (context, expenseProvider, routProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- Custom AppStatusBar ----------------
                const AppStatusBar(),
                // Optional: Custom header container instead of AppBar
                Container(
                  height: 50,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Center(
                        child: AutoTranslateText(
                          'Add New Expense',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExpenseTypeDropdown(),
                      const SizedBox(height: 12),
                      _buildTextField(controller: _reasonController, hint: 'Expense Reason',maxLength: 30,),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _amountController,
                        hint: 'Amount',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          MaxAmountInputFormatter(1000000000),
                          // <-- blocks everything except 0–9
                        ],
                      ),

                      const SizedBox(height: 12),
                      _buildRouteDropdown(routProvider),
                      const SizedBox(height: 12),
                      GestureDetector(onTap: _pickDate, child: _buildDatePicker()),
                      const SizedBox(height: 12),
                      GestureDetector(onTap: _pickDocument, child: _buildFilePicker()),
                      const SizedBox(height: 16),
                      _buildSubmitButton(expenseProvider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  // ---------------- Widgets: reuse from your previous code ----------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,  // <-- NEW PARAM
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: [
          ...?inputFormatters,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        decoration: InputDecoration(
          hintText: hint,
          counterText: "",   // hides the default counter
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }


  Widget _buildExpenseTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: const AutoTranslateText("Select Expense Type"),
        value: _selectedExpenseType,
        underline: const SizedBox(),
        items: expenseTypes.map((e) => DropdownMenuItem(value: e, child: AutoTranslateText(e))).toList(),
        onChanged: (val) => setState(() => _selectedExpenseType = val),
      ),
    );
  }

  Widget _buildRouteDropdown(RoutProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.error.isNotEmpty) return AutoTranslateText("Error: ${provider.error}", style: const TextStyle(color: Colors.red));
    if (provider.routes.isEmpty) return const AutoTranslateText("No routes found");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: const AutoTranslateText("Select Route"),
        value: _selectedRouteId,
        underline: const SizedBox(),
        items: provider.routes.map((route) => DropdownMenuItem(
          value: route.id.toString(),
          child: AutoTranslateText(route.routeName ?? "Route ${route.id}"),
        )).toList(),
        onChanged: (val) => setState(() => _selectedRouteId = val),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_selectedDate != null ? "${_selectedDate!.toLocal()}".split(" ")[0] : "Select Date",
            style: TextStyle(color: _selectedDate != null ? Colors.black : Colors.grey.shade600),
          ),
          const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildFilePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: AutoTranslateText(_pickedFileName ?? "Upload Document (Image/PDF)",
              style: TextStyle(color: _pickedFileName != null ? Colors.black : Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.attach_file, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ExpenseProvider provider) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : () async {
          if (_selectedExpenseType == null || _reasonController.text.isEmpty || _amountController.text.isEmpty || _selectedRouteId == null || _selectedDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AutoTranslateText("Please fill all fields")));
            return;
          }

          final formattedDate =
              "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

          final request = ExpenseAddRequest(
            expenseType: _selectedExpenseType!,
            expenseCost: double.tryParse(_amountController.text) ?? 0,
            expenseDocument: _pickedFileBase64 ?? "",
            routeId: _selectedRouteId!,
            reason: _reasonController.text,
            date: formattedDate,
          );

          await provider.addExpense(request);

          if (provider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AutoTranslateText(provider.errorMessage!)));
          } else if (provider.expenseResponse != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AutoTranslateText(provider.expenseResponse!.message)));
            _resetForm();
            Navigator.pop(context); // close page after successful submission
            Provider.of<ExpenseListProvider>(context, listen: false).fetchExpenses();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.topBarColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: provider.isLoading ? const CircularProgressIndicator(color: Colors.white) : const AutoTranslateText('Add Expense', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
