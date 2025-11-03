import 'package:flutter/material.dart';
import '../../../common/app_colors.dart';

Widget buildSectionHeader(String title, VoidCallback onAddTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      GestureDetector(
        onTap: onAddTap,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Colors.cyan, Colors.blue]),
          ),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ),
    ],
  );
}

Widget buildTableHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Expanded(flex: 2, child: Text("Product Name", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))),
        Expanded(child: Center(child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)))),
        Expanded(child: Align(alignment: Alignment.centerRight, child: Text("Prize", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)))),
      ],
    ),
  );
}

Widget buildTableRow(String name, String qty, String price) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text(name)),
        Expanded(child: Center(child: Text(qty))),
        Expanded(child: Align(alignment: Alignment.centerRight, child: Text(price))),
      ],
    ),
  );
}

Widget buildCollectionCard(String amount, String label) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Text(amount, style: TextStyle(color: AppColors.topBarColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}
