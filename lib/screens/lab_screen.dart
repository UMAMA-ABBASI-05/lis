import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LABScreen extends StatefulWidget {
  const LABScreen({super.key});

  @override
  State<LABScreen> createState() => _LABScreenState();
}

class _LABScreenState extends State<LABScreen> {
  static const Color primaryBlue = Color(0xFF1A3B5D);
  late Future<List<dynamic>> _labsFuture;

  @override
  void initState() {
    super.initState();
    _labsFuture = ApiService.getAllLabs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'LABs',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _labsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No LABs found',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final labs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: labs.length,
            itemBuilder: (_, i) {
              final l = labs[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_hospital_outlined,
                      color: primaryBlue,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l['name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                          Text(
                            'ID: ${l['lab_id'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
