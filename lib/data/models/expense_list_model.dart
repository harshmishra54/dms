// expense_model.dart
class ExpenseResponse {
  final int success;
  final String message;
  final List<Expense> data;

  ExpenseResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Expense.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class Expense {
  final String id;
  final String uId;
  final String userId;
  final String? routeId;
  final String reason;
  final String? expenseDocument;
  final double expenseCost; // Changed to double
  final String expenseType;
  final String date;
  final String isStatus;

  Expense({
    required this.id,
    required this.uId,
    required this.userId,
    this.routeId,
    required this.reason,
    this.expenseDocument,
    required this.expenseCost,
    required this.expenseType,
    required this.date,
    required this.isStatus,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      uId: json['u_id'] ?? '',
      userId: json['user_id'] ?? '',
      routeId: json['route_id'],
      reason: json['reason'] ?? '',
      expenseDocument: json['bill_document'], // renamed to match API
      expenseCost: double.tryParse(json['expense_cost'].toString()) ?? 0, // safe parsing
      expenseType: json['expense_type'] ?? '',
      date: json['date'] ?? '',
      isStatus: json['isStatus'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'u_id': uId,
      'user_id': userId,
      'route_id': routeId,
      'reason': reason,
      'bill_document': expenseDocument,
      'expense_cost': expenseCost,
      'expense_type': expenseType,
      'date': date,
      'isStatus': isStatus,
    };
  }
}

