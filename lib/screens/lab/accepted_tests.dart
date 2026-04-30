import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'test_result_entry.dart';

class AcceptedTestsScreen extends StatefulWidget {
  const AcceptedTestsScreen({super.key});
  @override
  State<AcceptedTestsScreen> createState() => _AcceptedTestsScreenState();
}

class _AcceptedTestsScreenState extends State<AcceptedTestsScreen> {
  List<dynamic> _all = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _searchBy = 'Name';

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearch);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getAcceptedList();
      setState(() {
        _all = data;
        _filtered = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _all.where((p) {
        if (_searchBy == 'MPI') {
          return p['mpi']?.toString().contains(q) ?? false;
        }
        final name = '${p['fname'] ?? ''} ${p['lname'] ?? ''}'.toLowerCase();
        return name.contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: const Text(
                'Accepted Test',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Search Patient',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3B5D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _searchBy,
                        dropdownColor: const Color(0xFF1A3B5D),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 18,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        items: ['Name', 'MPI']
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(
                                  v,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() => _searchBy = v!);
                          _onSearch();
                        },
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
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: _filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No accepted tests',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) {
                                final p = _filtered[i];
                                return _AcceptedTile(
                                  patient: p,
                                  onTap: () async {
                                    final testReqId =
                                        p['test_req_id']?.toString() ?? '';
                                    final locked =
                                        await ApiService.lockByTestReqId(
                                          testReqId,
                                        );
                                    if (!mounted) return;
                                    if (!locked) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Locked by another user',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TestResultEntryScreen(
                                          testReqId: testReqId,
                                          patientName:
                                              '${p['fname'] ?? ''} ${p['lname'] ?? ''}'
                                                  .trim(),
                                          testName: p['test_name'] ?? 'Test',
                                        ),
                                      ),
                                    );
                                    _load();
                                  },
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcceptedTile extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onTap;
  const _AcceptedTile({required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = '${patient['fname'] ?? ''} ${patient['lname'] ?? ''}'.trim();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFEAF2FF),
              child: Icon(Icons.person, color: Color(0xFF1A3B5D), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    'MPI: ${patient['mpi'] ?? ''}, VID: ${patient['vid'] ?? ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Date: ${patient['updated_at'] ?? patient['date'] ?? ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    patient['test_name'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A3B5D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
