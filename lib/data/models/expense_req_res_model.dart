class ExpenseAddRequest {
  final String expenseType;
  final double expenseCost;
  final String? expenseDocument; // image/pdf/null
  final String routeId;
  final String reason;
  final String date; // YYYY-MM-DD format (Required)

  ExpenseAddRequest({
    required this.expenseType,
    required this.expenseCost,
    this.expenseDocument,
    required this.routeId,
    required this.reason,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      "expense_type": expenseType,
      "expense_cost": expenseCost,
      "expense_document": expenseDocument ?? "", // backend expects "" if null
      "route_id": routeId,
      "reason": reason,
      "date": date, // add date here
    };
  }
}

class ExpenseAddResponse {
  final int success;
  final String message;

  ExpenseAddResponse({
    required this.success,
    required this.message,
  });

  factory ExpenseAddResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseAddResponse(
      success: int.tryParse(json["success"].toString()) ?? 0, // handle string/int
      message: json["message"] ?? json["messgae"] ?? "", // fix typo fallback
    );
  }
}
