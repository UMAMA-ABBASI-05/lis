import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_manager.dart';

class TestResultEntryScreen extends StatefulWidget {
  final String testReqId;
  final String patientName;
  final String testName;
  const TestResultEntryScreen({
    super.key,
    required this.testReqId,
    required this.patientName,
    required this.testName,
  });
  @override
  State<TestResultEntryScreen> createState() => _TestResultEntryScreenState();
}

class _TestResultEntryScreenState extends State<TestResultEntryScreen> {
  final _summaryCtrl = TextEditingController();
  final List<Map<String, TextEditingController>> _rows = [];
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // _lockAndLoad();
    _loadExistingResult();
  }

  // Future<void> _lockAndLoad() async {
  //   final locked = await ApiService.lockByTestReqId(widget.testReqId);
  //   if (!mounted) return;
  //
  //   if (!locked) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Screen is locked by another user'),
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
  //   await _loadExistingResult();
  // }

  Future<void> _loadExistingResult() async {
    try {
      final data = await ApiService.getTestResult(widget.testReqId);
      _summaryCtrl.text = data['description'] ?? '';
      final miniResults = (data['mini_test_results'] as List?) ?? [];
      if (miniResults.isNotEmpty) {
        _rows.clear();
        for (final r in miniResults) {
          _rows.add({
            'test_name': TextEditingController(text: r['test_name'] ?? ''),
            'normal_range': TextEditingController(
                text: r['normal_range'] ?? ''),
            'unit': TextEditingController(text: r['units'] ?? ''),
            'result_value': TextEditingController(
                text: r['result_value'] ?? ''),
          });
        }
      } else {
        _addRow();
      }
    } catch (_) {
      _addRow();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Future<void> _unlockAndPop() async {
  //   await ApiService.unlockByTestReqId(widget.testReqId);
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Screen unlocked'),
  //         backgroundColor: Colors.grey,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     Navigator.pop(context);
  //   }
  // }

  void _addRow() {
    setState(() {
      _rows.add({
        'test_name': TextEditingController(),
        'normal_range': TextEditingController(),
        'unit': TextEditingController(),
        'result_value': TextEditingController(),
      });
    });
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      for (final c in _rows[index].values) c.dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final miniResults = _rows
          .map((r) => {
                'test_name': r['test_name']!.text,
                'normal_range': r['normal_range']!.text,
                'unit': r['unit']!.text,
                'result_value': r['result_value']!.text,
              })
          .toList();

      await ApiService.addCompleteResult({
        'test_req_id': int.tryParse(widget.testReqId) ?? widget.testReqId,
        'description': _summaryCtrl.text,
        'mini_test_results': miniResults,
      });

      // await ApiService.unlockByTestReqId(widget.testReqId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Result saved!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      // await ApiService.unlockByTestReqId(widget.testReqId);
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
    _summaryCtrl.dispose();
    // ApiService.unlockByTestReqId(widget.testReqId);
    for (final r in _rows) for (final c in r.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // await ApiService.unlockByTestReqId(widget.testReqId);
        // if (mounted)
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('Screen unlocked'),
        //       backgroundColor: Colors.grey,
        //       duration: Duration(seconds: 2),
        //     ),
        //   );
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
                      onPressed: () => Navigator.pop(context),
                      // onPressed: _unlockAndPop,
                    ),
                    const Text(
                      'Add Test Result',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      // onPressed: _unlockAndPop,
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
                            color: Color(0xFF1A3B5D)),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Test Result',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A3B5D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Patient: ${widget.patientName}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Test: ${widget.testName}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Report Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A3B5D),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFEEEEEE)),
                              ),
                              child: TextField(
                                controller: _summaryCtrl,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Summary...',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(14),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            const Text(
                              'Results',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A3B5D),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Table header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text('Parameters',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xFF1A3B5D))),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('Normal Range',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xFF1A3B5D))),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('Units',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xFF1A3B5D))),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('Results',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xFF1A3B5D))),
                                  ),
                                  SizedBox(width: 24),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),
                            ...List.generate(
                                _rows.length, (i) => _buildRow(i)),

                            TextButton.icon(
                              onPressed: _addRow,
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Color(0xFF1A3B5D)),
                              label: const Text('Add Row',
                                  style: TextStyle(
                                      color: Color(0xFF1A3B5D))),
                            ),

                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A3B5D),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                onPressed: _saving ? null : _save,
                                child: _saving
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text('Save',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.bold)),
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

  Widget _buildRow(int index) {
    final r = _rows[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          _miniField(r['test_name']!, flex: 3, hint: 'Parameter'),
          _miniField(r['normal_range']!, flex: 2, hint: 'Range'),
          _miniField(r['unit']!, flex: 2, hint: 'Unit'),
          _miniField(r['result_value']!, flex: 2, hint: 'Value'),
          GestureDetector(
            onTap: () => _removeRow(index),
            child: const Icon(Icons.delete_outline,
                color: Color(0xFFE74C3C), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _miniField(
    TextEditingController ctrl, {
    required int flex,
    required String hint,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Colors.grey, fontSize: 11),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 6, horizontal: 4),
          ),
        ),
      ),
    );
  }
}