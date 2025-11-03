import 'package:flutter/material.dart';
import '../../../../core/utils/state_district_data.dart';

class DistrictSelectionScreen extends StatelessWidget {
  final String selectedState;
  final Function(String) onDistrictSelected;

  const DistrictSelectionScreen({
    super.key,
    required this.selectedState,
    required this.onDistrictSelected,
  });

  @override
  Widget build(BuildContext context) {
    final districts = stateDistrictMap[selectedState] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select District'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: districts.length,
        itemBuilder: (context, index) {
          final district = districts[index];
          return ListTile(
            title: Text(district),
            onTap: () {
              onDistrictSelected(district);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
