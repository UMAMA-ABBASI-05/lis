import 'package:flutter/material.dart';
import 'package:lis/screens/patient/test_result_view_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../lab/test_result_entry.dart';

class PatientReportsHistoryScreen extends StatefulWidget {
  final String nic;
  final String patientName;

  const PatientReportsHistoryScreen({
    super.key,
    required this.nic,
    required this.patientName,
  });

  @override
  State<PatientReportsHistoryScreen> createState() =>
      _PatientReportsHistoryScreenState();
}

class _PatientReportsHistoryScreenState
    extends State<PatientReportsHistoryScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final labId = prefs.getString('lab_id') ?? '';

    try {
      final data = await ApiService.getPatientDetails(widget.nic, labId);

      print('LAB REPORTS: ${data['lab_reports']}');

      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = (_data?['lab_reports'] as List?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A3B5D),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Patient Info
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFEEEEEE),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Patient: ${widget.patientName}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A3B5D),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                _row('NIC:', widget.nic),

                                _row(
                                  'Age:',
                                  _data?['age']?.toString() ?? 'N/A',
                                ),

                                _row('Gender:', _data?['gender'] ?? 'N/A'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Lab Reports',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (reports.isEmpty)
                            const Center(
                              child: Text(
                                'No reports',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
                            ...reports.map((r) {
                              final status = r['status'] ?? '';

                              final isAccepted =
                                  status.toLowerCase() == 'accepted';

                              final isCompleted =
                                  status.toLowerCase() == 'completed';

                              return GestureDetector(
                                onTap: isAccepted
                                    ? () {
                                        print("REPORT ID: ${r['report_id']}");

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TestResultEntryScreen(
                                                  testReqId:
                                                      r['report_id']
                                                          ?.toString() ??
                                                      '',
                                                  patientName:
                                                      widget.patientName,
                                                  patientNic: widget.nic,
                                                  testName:
                                                      r['test_name'] ?? 'Test',
                                                  testCode:
                                                      r['test_code']
                                                          ?.toString() ??
                                                      '',
                                                ),
                                          ),
                                        );
                                      }
                                    : isCompleted
                                    ? () {
                                        print("REPORT ID: ${r['report_id']}");

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TestResultViewScreen(
                                                  testReqId:
                                                      r['report_id']
                                                          ?.toString() ??
                                                      '',
                                                  patientName:
                                                      widget.patientName,
                                                  testName:
                                                      r['test_name'] ?? 'Test',
                                                ),
                                          ),
                                        );
                                      }
                                    : null,

                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),

                                  padding: const EdgeInsets.all(14),

                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFDDE8F8),
                                    ),
                                  ),

                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),

                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEAF2FF),

                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),

                                        child: const Icon(
                                          Icons.assignment_outlined,
                                          color: Color(0xFF1A3B5D),
                                          size: 20,
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              r['test_name'] ?? 'Test',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Color(0xFF1A1A2E),
                                              ),
                                            ),

                                            Text(
                                              'VID: ${r['vid'] ?? ''}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),

                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 4,
                                              ),

                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),

                                              decoration: BoxDecoration(
                                                color: isCompleted
                                                    ? Colors.green.withOpacity(
                                                        0.1,
                                                      )
                                                    : isAccepted
                                                    ? Colors.blue.withOpacity(
                                                        0.1,
                                                      )
                                                    : Colors.orange.withOpacity(
                                                        0.1,
                                                      ),

                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),

                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isCompleted
                                                      ? Colors.green
                                                      : isAccepted
                                                      ? Colors.blue
                                                      : Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
