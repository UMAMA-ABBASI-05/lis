import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/session_manager.dart';

class TestResultEntryScreen extends StatefulWidget {
  final String testReqId;
  final String patientName;
  final String patientNic; // ← NEW: NIC chahiye GET parameters API ke liye
  final String testName;
  final String testCode; // ← NEW: test_code chahiye POST API ke liye

  const TestResultEntryScreen({
    super.key,
    required this.testReqId,
    required this.patientName,
    required this.patientNic,
    required this.testName,
    required this.testCode,
  });

  @override
  State<TestResultEntryScreen> createState() => _TestResultEntryScreenState();
}

class _TestResultEntryScreenState extends State<TestResultEntryScreen> {
  final _summaryCtrl = TextEditingController();

  /// Har row mein: parameter (read-only), normal_range (read-only),
  /// unit (read-only), aur result_value_ctrl (sirf yahi editable hai)
  final List<Map<String, dynamic>> _rows = [];

  bool _saving = false;
  bool _loading = true;

  // ─────────────────────────────────────────────────────────────────
  // INIT — pehle existing result check karo, warna parameters load karo
  // ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 1️⃣ Pehle existing result dekho (edit flow)
      try {
        final existing = await ApiService.getTestResult(widget.testReqId);
        _summaryCtrl.text = existing['description'] ?? '';
        final miniResults = (existing['mini_test_results'] as List?) ?? [];
        if (miniResults.isNotEmpty) {
          _rows.clear();
          for (final r in miniResults) {
            _rows.add({
              'parameter': r['test_name'] ?? '',
              'normal_range': r['normal_range'] ?? '',
              'unit': r['units'] ?? '',
              'result_value_ctrl': TextEditingController(
                text: r['result_value'] ?? '',
              ),
            });
          }
          if (mounted) setState(() => _loading = false);
          return; // existing data mil gayi, parameters API skip karo
        }
      } catch (_) {
        // koi existing result nahi — aage chalo
      }

      // 2️⃣ GET /requests/take_test_parameters/{nic}/{test_req_id}
      //    — yahan se parameters, normal_range, unit aate hain
      final params = await ApiService.getTestParameters(
        nic: widget.patientNic,
        testReqId: widget.testReqId,
        testName: widget.testName,
      );

      // Parameters API se aaya test_code SharedPreferences mein save karo
      if (params.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'test_code',
          params.first['test_code']?.toString() ?? '',
        );
      }

      _rows.clear();
      for (final p in params) {
        _rows.add({
          'parameter': p['parameter'] ?? p['test_name'] ?? '',
          'normal_range': p['test_range'] ?? '',
          'unit': p['unit'] ?? '',
          'result_value_ctrl': TextEditingController(),
        });
      }

      // Agar API ne koi parameter nahi diya toh ek blank row show karo
      if (_rows.isEmpty) _rows.add(_emptyRow());
    } catch (_) {
      _rows.add(_emptyRow());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _emptyRow() => {
    'parameter': '',
    'normal_range': '',
    'unit': '',
    'result_value_ctrl': TextEditingController(),
  };

  // ─────────────────────────────────────────────────────────────────
  // SAVE — POST /results/complete
  // ─────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    // Check karo ke sab result values bhari hain
    final empty = _rows.any(
      (r) =>
          (r['result_value_ctrl'] as TextEditingController).text.trim().isEmpty,
    );
    if (empty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all result values'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final userId = await SessionManager.getUserId();
      final prefs = await SharedPreferences.getInstance();
      final testCode = prefs.getString('test_code') ?? '';

      final miniTests = _rows
          .map(
            (r) => {
              'test_name': r['parameter'],
              'normal_range': r['normal_range'],
              'units': r['unit'],
              'result_value': (r['result_value_ctrl'] as TextEditingController)
                  .text
                  .trim(),
            },
          )
          .toList();

      // POST /results/complete
      await ApiService.addCompleteResult({
        'user_id': userId,
        'lab_id': prefs.getString('lab_id') ?? '',
        'test_req_id': int.tryParse(widget.testReqId) ?? widget.testReqId,
        'test_code': testCode,
        'description': _summaryCtrl.text.trim(),
        'mini_tests': miniTests,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Result saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // true = refresh parent list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _summaryCtrl.dispose();
    for (final r in _rows) {
      (r['result_value_ctrl'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A3B5D),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPatientHeader(),
                          const SizedBox(height: 24),
                          _buildSummaryCard(),
                          const SizedBox(height: 24),
                          _buildResultsCard(),
                          const SizedBox(height: 28),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ─────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF1A3B5D),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Add Test Result',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
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
    );
  }

  // ── PATIENT HEADER ───────────────────────────────────────────────
  Widget _buildPatientHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient: ${widget.patientName}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3B5D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.testName,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  // ── SUMMARY CARD ─────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.testName} Report Summary',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3B5D),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _summaryCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Summary...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }

  // ── RESULTS CARD ─────────────────────────────────────────────────
  Widget _buildResultsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Results',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3B5D),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EDF3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: [
                // ── Table Header ──────────────────────────────────
                _buildTableHeader(),
                // ── Rows ─────────────────────────────────────────
                ...List.generate(_rows.length, (i) {
                  return Column(
                    children: [
                      _buildTableRow(i),
                      if (i < _rows.length - 1)
                        const Divider(
                          height: 1,
                          color: Color(0xFFF0F3F8),
                          indent: 12,
                          endIndent: 12,
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: const Color(0xFFEAF2FF),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Parameters',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Color(0xFF1A3B5D),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Normal Range',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Color(0xFF1A3B5D),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Units',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Color(0xFF1A3B5D),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Results',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Color(0xFF1A3B5D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(int index) {
    final r = _rows[index];
    final ctrl = r['result_value_ctrl'] as TextEditingController;
    final isEven = index % 2 == 0;

    return Container(
      color: isEven ? Colors.white : const Color(0xFFFAFCFF),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Parameter name — READ ONLY
          Expanded(
            flex: 3,
            child: Text(
              r['parameter'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1A3B5D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Normal Range — READ ONLY
          Expanded(
            flex: 2,
            child: Text(
              r['normal_range'] as String,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ),
          // Unit — READ ONLY
          Expanded(
            flex: 2,
            child: Text(
              r['unit'] as String,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ),
          // Result Value — EDITABLE (sirf yahi user bharta hai)
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB8D0F0)),
              ),
              child: TextField(
                controller: ctrl,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3B5D),
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  hintText: '—',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SAVE BUTTON ──────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A3B5D),
          disabledBackgroundColor: const Color(0xFF1A3B5D).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
          shadowColor: const Color(0xFF1A3B5D).withOpacity(0.4),
        ),
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
