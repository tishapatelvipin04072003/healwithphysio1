// import 'package:flutter/material.dart';

// class RejectReasonScreen extends StatefulWidget {
//   const RejectReasonScreen({super.key});

//   @override
//   _RejectReasonScreenState createState() => _RejectReasonScreenState();
// }

// class _RejectReasonScreenState extends State<RejectReasonScreen> {
//   String? selectedReason;
//   TextEditingController otherReasonController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Reject Appointment"),
//         backgroundColor: Colors.indigo[900],
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 50,),
//             Text(
//               "Why Are You Rejecting This Appointment?",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             RadioListTile<String>(
//               title: Row(
//                 children: [
//                   Icon(Icons.schedule, color: Colors.red),
//                   SizedBox(width: 8),
//                   Expanded(child: Text("Time Conflict – The requested time is not available.")),
//                 ],
//               ),
//               value: "Time Conflict",
//               groupValue: selectedReason,
//               onChanged: (value) {
//                 setState(() {
//                   selectedReason = value;
//                 });
//               },
//             ),
//             RadioListTile<String>(
//               title: Row(
//                 children: [
//                   Icon(Icons.location_off, color: Colors.red),
//                   SizedBox(width: 8),
//                   Expanded(child: Text("Location Issue – The patient's location is too far or out of service area.")),
//                 ],
//               ),
//               value: "Location Issue",
//               groupValue: selectedReason,
//               onChanged: (value) {
//                 setState(() {
//                   selectedReason = value;
//                 });
//               },
//             ),
//             RadioListTile<String>(
//               title: Row(
//                 children: [
//                   Icon(Icons.person_off, color: Colors.red),
//                   SizedBox(width: 8),
//                   Expanded(child: Text("Patient Condition Not Suitable – The case requires a specialist or is outside my expertise.")),
//                 ],
//               ),
//               value: "Patient Condition Not Suitable",
//               groupValue: selectedReason,
//               onChanged: (value) {
//                 setState(() {
//                   selectedReason = value;
//                 });
//               },
//             ),
//             RadioListTile<String>(
//               title: Row(
//                 children: [
//                   Icon(Icons.warning_amber, color: Colors.red),
//                   SizedBox(width: 8),
//                   Expanded(child: Text("Emergency or Personal Reasons – Unforeseen circumstances prevent attending.")),
//                 ],
//               ),
//               value: "Emergency or Personal Reasons",
//               groupValue: selectedReason,
//               onChanged: (value) {
//                 setState(() {
//                   selectedReason = value;
//                 });
//               },
//             ),
//             RadioListTile<String>(
//               title: Row(
//                 children: [
//                   Icon(Icons.more_horiz, color: Colors.red),
//                   SizedBox(width: 8),
//                   Expanded(child: Text("Other")),
//                 ],
//               ),
//               value: "Other",
//               groupValue: selectedReason,
//               onChanged: (value) {
//                 setState(() {
//                   selectedReason = value;
//                 });
//               },
//             ),
//             if (selectedReason == "Other") ...[
//               SizedBox(height: 10),
//               TextField(
//                 controller: otherReasonController,
//                 decoration: InputDecoration(
//                   labelText: "Enter reason",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                   ),
//                 ),
//               ),
//             ],
//             Spacer(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (selectedReason == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("Please select a reason")),
//                     );
//                     return;
//                   }

//                   String finalReason = selectedReason == "Other"
//                       ? otherReasonController.text
//                       : selectedReason!;

//                   // Handle rejection logic
//                   print("Rejected because: $finalReason");

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Appointment rejected"),
//                       backgroundColor: Colors.red,
//                     ),
//                   );

//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: 16.0),
//                   backgroundColor: Colors.red,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                   ),
//                 ),
//                 child: Text(
//                   "Reject Appointment",
//                   style: TextStyle(fontSize: 18.0, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:heal_with_physio/main.dart';

class RejectReasonScreen extends StatefulWidget {
  final int appointmentId;

  const RejectReasonScreen({super.key, required this.appointmentId});

  @override
  _RejectReasonScreenState createState() => _RejectReasonScreenState();
}

class _RejectReasonScreenState extends State<RejectReasonScreen> {
  String? selectedReason;
  TextEditingController otherReasonController = TextEditingController();

  Future<void> rejectAppointment() async {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a reason")),
      );
      return;
    }

    String finalReason = selectedReason == "Other" ? otherReasonController.text : selectedReason!;

    if (finalReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a reason")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/reject_appointment.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appointment_id': widget.appointmentId,
          'rejection_reason': finalReason,
        }),
      );

      print('Reject Response status: ${response.statusCode}');
      print('Reject Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Unknown response'),
            backgroundColor: data['status'] == 'success' ? Colors.green : Colors.red,
          ),
        );
        if (data['status'] == 'success') {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reject appointment')),
        );
      }
    } catch (e) {
      print('Reject Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reject Appointment"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Text(
              "Why Are You Rejecting This Appointment?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            RadioListTile<String>(
              title: Row(
                children: const [
                  Icon(Icons.schedule, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text("Time Conflict \n – The requested time is not available.")),
                ],
              ),
              value: "Time Conflict",
              groupValue: selectedReason,
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                });
              },
            ),
            SizedBox(height: 20,),
            RadioListTile<String>(
              title: Row(
                children: const [
                  Icon(Icons.location_off, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text("Location Issue \n – The patient's location is too far or out of service area.")),
                ],
              ),
              value: "Location Issue",
              groupValue: selectedReason,
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                });
              },
            ),
            SizedBox(height: 20,),
            RadioListTile<String>(
              title: Row(
                children: const [
                  Icon(Icons.warning_amber, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text("Emergency or Personal Reasons \n – Unforeseen circumstances prevent attending.")),
                ],
              ),
              value: "Emergency or Personal Reasons",
              groupValue: selectedReason,
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                });
              },
            ),
            SizedBox(height: 20,),
            RadioListTile<String>(
              title: Row(
                children: const [
                  Icon(Icons.more_horiz, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text("Other")),
                ],
              ),
              value: "Other",
              groupValue: selectedReason,
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                });
              },
            ),
            if (selectedReason == "Other") ...[
              const SizedBox(height: 10),
              TextField(
                controller: otherReasonController,
                decoration: InputDecoration(
                  labelText: "Enter reason",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: rejectAppointment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  "Reject Appointment",
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    otherReasonController.dispose();
    super.dispose();
  }
}