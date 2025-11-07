import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/Attendance_form.dart';
import 'package:flutter/material.dart';

class AttendancePopup extends StatelessWidget {
  const AttendancePopup({super.key});

  void _openForm(BuildContext context, String mode) {
    Navigator.pop(context); // close popup
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceFormScreen(mode: mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: const [
                Icon(Icons.access_time, color: Colors.blue, size: 30),
                SizedBox(width: 10),
                AutoTranslateText(
                  "Mark Attendance",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Message
            const AutoTranslateText(
              "Please select your status for today:",
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // On Leave Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openForm(context, "leave"),
                    icon: const Icon(Icons.free_cancellation, color: Colors.white),
                    label: const AutoTranslateText("On Leave",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // Working Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openForm(context, "working"),
                    icon: const Icon(Icons.work_outline, color: Colors.white),
                    label: const AutoTranslateText("Working",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
