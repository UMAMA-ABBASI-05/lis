import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TestResultViewScreen extends StatefulWidget {
  final String testReqId;
  final String patientName;
  final String testName;

  const TestResultViewScreen({
    super.key,
    required this.testReqId,
    required this.patientName,
    required this.testName,
  });

  @override
  State<TestResultViewScreen> createState() => _TestResultViewScreenState();
}

class _TestResultViewScreenState extends State<TestResultViewScreen> {
  bool _loading = true;
  String _description = '';
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    try {
      final data = await ApiService.getTestResult(widget.testReqId);
      _description = data['description'] ?? '';
      final miniResults = (data['mini_test_results'] as List?) ?? [];
      _rows = miniResults
          .map(
            (r) => {
              'test_name': r['test_name'] ?? '',
              'normal_range': r['normal_range'] ?? '',
              'units': r['units'] ?? '',
              'result_value': r['result_value'] ?? '',
            },
          )
          .toList();
    } catch (_) {
      _rows = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
            'Test Result',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Spacer(),
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
          width: double.infinity,
          padding: const EdgeInsets.all(14),
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
          child: Text(
            _description.isEmpty ? 'No summary available.' : _description,
            style: TextStyle(
              fontSize: 13,
              color: _description.isEmpty
                  ? Colors.grey
                  : const Color(0xFF333333),
              height: 1.5,
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
                _buildTableHeader(),
                if (_rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No results found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
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
    final isEven = index % 2 == 0;

    // Check if result is outside normal range (highlight in red)
    final resultVal = double.tryParse(r['result_value'].toString());
    final rangeStr = r['normal_range'].toString();
    bool isAbnormal = false;
    if (resultVal != null && rangeStr.contains('–')) {
      final parts = rangeStr.split('–');
      if (parts.length == 2) {
        final low = double.tryParse(parts[0].trim().replaceAll(',', ''));
        final high = double.tryParse(parts[1].trim().replaceAll(',', ''));
        if (low != null && high != null) {
          isAbnormal = resultVal < low || resultVal > high;
        }
      }
    }

    return Container(
      color: isEven ? Colors.white : const Color(0xFFFAFCFF),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Parameter — READ ONLY
          Expanded(
            flex: 3,
            child: Text(
              r['test_name'],
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
              r['normal_range'],
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ),
          // Units — READ ONLY
          Expanded(
            flex: 2,
            child: Text(
              r['units'],
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ),
          // Result Value — READ ONLY, abnormal = red
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isAbnormal
                    ? Colors.red.withOpacity(0.08)
                    : const Color(0xFFF0F5FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAbnormal
                      ? Colors.red.withOpacity(0.4)
                      : const Color(0xFFB8D0F0),
                ),
              ),
              child: Text(
                r['result_value'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAbnormal ? Colors.red : const Color(0xFF1A3B5D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
