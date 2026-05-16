import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_manager.dart';
import '../lab/test_result_entry.dart';

class LabPatientDetailsScreen extends StatefulWidget {
  final String nic;
  final String vid;
  const LabPatientDetailsScreen({
    super.key,
    required this.nic,
    required this.vid,
  });
  @override
  State<LabPatientDetailsScreen> createState() =>
      _LabPatientDetailsScreenState();
}

class _LabPatientDetailsScreenState extends State<LabPatientDetailsScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _saving = false;
  final Map<String, String> _statusMap = {};
  final Map<String, TextEditingController> _amountCtrl = {};

  @override
  void initState() {
    super.initState();
    // _lockAndLoad();
    _load();
  }

  // Future<void> _lockAndLoad() async {
  //   final locked = await ApiService.lockByVisitId(widget.vid);
  //   if (!mounted) return;
  //
  //   if (!locked) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('This screen is locked by another user'),
  //         backgroundColor: Colors.orange,
  //       ),
  //     );
  //     Navigator.pop(context);
  //     return;
  //   }
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Screen locked by you'),
  //       backgroundColor: Color(0xFF1A3B5D),
  //       duration: Duration(seconds: 2),
  //     ),
  //   );
  //
  //   _load();
  // }

  Future<void> _load() async {
    try {
      final data = await ApiService.getPatientProcess(widget.nic, widget.vid);
      final tests = (data['lab_reports'] as List?) ?? [];
      for (final t in tests) {
        final id = t['report_id']?.toString() ?? '';
        _statusMap[id] = t['status'] ?? 'Pending';
        _amountCtrl[id] = TextEditingController(
          text: t['test_amount']?.toString() ?? '',
        );
      }
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<void> _unlockAndPop() async {
    // await ApiService.unlockByVisitId(widget.vid);
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Screen unlocked'),
    //       backgroundColor: Colors.grey,
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    // }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final userId = await SessionManager.getUserId() ?? 0;
      final tests = (_data?['lab_reports'] as List?) ?? [];

      final Map<String, String> reqIdStatus = {};
      final Map<String, double> reqIdBill = {};

      for (final t in tests) {
        final id = t['report_id']?.toString() ?? '';
        reqIdStatus[id] = _statusMap[id] ?? 'Pending';
        reqIdBill[id] = double.tryParse(_amountCtrl[id]?.text ?? '0') ?? 0.0;
      }

      final ok = await ApiService.updateReportStatus(
        reqIdStatus: reqIdStatus,
        reqIdBill: reqIdBill,
        userId: userId,
        visitId: widget.vid,
      );

      if (!mounted) return;

      if (ok) {
        // await ApiService.unlockByVisitId(widget.vid);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Save failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    // ApiService.unlockByVisitId(widget.vid);
    for (final c in _amountCtrl.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = '${_data?['fname'] ?? ''} ${_data?['lname'] ?? ''}'.trim();
    final tests = (_data?['lab_reports'] as List?) ?? [];

    return WillPopScope(
      onWillPop: () async {
        // await ApiService.unlockByVisitId(widget.vid);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Screen unlocked'),
        //     backgroundColor: Colors.grey,
        //     duration: Duration(seconds: 2),
        //   ),
        // );
        return true;
      },
      child: Scaffold(
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
                      onPressed: _unlockAndPop,
                    ),
                    const Text(
                      'View pending tests',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _unlockAndPop,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Color(0xFF1A3B5D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                                    'Patient: $name',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A3B5D),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _row(
                                    'nic:',
                                    _data?['nic']?.toString() ?? widget.nic,
                                  ),
                                  _row('VID:', widget.vid),
                                  _row('Gender:', _data?['gender'] ?? 'N/A'),
                                  _row(
                                    'Age:',
                                    _data?['age']?.toString() ?? 'N/A',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Lab Tests',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...tests.map((t) {
                              final id = t['report_id']?.toString() ?? '';
                              final testName = t['test_name'] ?? 'Test';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          testName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF1A1A2E),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A3B5D),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value:
                                                  _statusMap[id] ?? 'Pending',
                                              dropdownColor: const Color(
                                                0xFF1A3B5D,
                                              ),
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                              items:
                                                  [
                                                        'Pending',
                                                        'Accepted',
                                                        'Declined',
                                                      ]
                                                      .map(
                                                        (s) => DropdownMenuItem(
                                                          value: s,
                                                          child: Text(
                                                            s,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                              onChanged: (v) => setState(
                                                () => _statusMap[id] = v!,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _amountCtrl[id],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Test Amount',
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF5F5F5),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A3B5D),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _saving ? null : _save,
                                child: _saving
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Save',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
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
