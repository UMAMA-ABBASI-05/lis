import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'session_manager.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.31.246:8002';
  static Future<List<dynamic>> getAllLabs() async {
    final res = await http.get(Uri.parse('$baseUrl/all-labs'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load labs');
  }

  // Admin Login
  static Future<Map<String, dynamic>> loginAdmin(
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login-admin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print("Admin Login Status: ${res.statusCode}");
      print("Admin Login Body: ${res.body}");
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {'success': true, ...data};
      }
      final error = jsonDecode(res.body);
      return {'success': false, 'message': error['detail'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Add Lab
  static Future<Map<String, dynamic>> addLab(String name) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/add-lab?name=$name'), // ← query param
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 201 || res.statusCode == 200)
        return {'success': true, ...data};
      return {'success': false, 'message': data['detail'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<bool> changeConfigStatus(bool holdFlag) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/change-config-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'hold_flag': holdFlag}),
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Send Config to Engine
  static Future<bool> sendConfigToEngine() async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/sent-config-to-engine'));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Config History
  static Future<List<dynamic>> getConfigHistory() async {
    final res = await http.get(Uri.parse('$baseUrl/config-history'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load history');
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
    String labId,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'lab_id': labId, // ← add karo
      }),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    final error = jsonDecode(res.body);
    throw Exception(error['detail'] ?? 'Login failed');
  }

  static Future<void> signup(
    String userName,
    String email,
    String password,
    String labId,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/SignUp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_name': userName,
        'email': email,
        'password': password,
        'lab_id': labId, // ← add karo
      }),
    );
    if (res.statusCode != 201) {
      final error = jsonDecode(res.body);
      throw Exception(error['detail'] ?? 'Signup failed');
    }
  }

  static Future<List<dynamic>> getWaitingList(String labId) async {
    final res = await http.get(Uri.parse('$baseUrl/patient-waiting-list/$labId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load waiting list');
  }

  static Future<List<dynamic>> getAcceptedList(String labId) async {
    final res = await http.get(Uri.parse('$baseUrl/patient-Accepted-list/$labId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load accepted list');
  }

  static Future<Map<String, dynamic>> getPatientProcess(
    String nic,
    String vid,
  ) async {
    final res = await http.get(Uri.parse('$baseUrl/patient-process/$nic/$vid'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load patient process');
  }

  static Future<List<dynamic>> getAllPatients(String labId) async {
   
    final res = await http.get(Uri.parse('$baseUrl/get_patients/$labId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load patients');
  }

  static Future<Map<String, dynamic>> getPatientDetails(String nic, String labId) async {
    final res = await http.get(Uri.parse('$baseUrl/patients/$nic/$labId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load patient details');
  }

  static Future<bool> lockByVisitId(String vid) async {
    final userId = await SessionManager.getUserId();
    final res = await http.put(
      Uri.parse(
        '$baseUrl/requests/lock_test_request/visit_id/$vid/user_id/$userId',
      ),
    );
    // 403 = already locked by someone else
    if (res.statusCode == 403) return false;
    return res.statusCode == 200;
  }

  static Future<void> unlockByVisitId(String vid) async {
    final userId = await SessionManager.getUserId();
    await http.put(
      Uri.parse(
        '$baseUrl/requests/unlock_test_request/visit_id/$vid/user_id/$userId',
      ),
    );
  }

  static Future<bool> lockByTestReqId(String testReqId) async {
    final userId = await SessionManager.getUserId();
    final res = await http.put(
      Uri.parse('$baseUrl/requests/lock_test/$testReqId/user_id/$userId'),
    );
    return res.statusCode == 200;
  }

  static Future<void> unlockByTestReqId(String testReqId) async {
    final userId = await SessionManager.getUserId();
    await http.put(
      Uri.parse(
        '$baseUrl/requests/unlock_test_request/test_req_id/$testReqId/user_id/$userId',
      ),
    );
  }

  static Future<bool> updateReportStatus({
    required Map<String, String> reqIdStatus, // ← String
    required Map<String, double> reqIdBill, // ← String
    required int userId,
    required String visitId,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/requests/update_report_status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'req_id_status': reqIdStatus,
        'req_id_bill': reqIdBill,
        'user_id': userId,
        'visit_id': visitId,
      }),
    );
    return res.statusCode == 200;
  }

  static Future<Map<String, dynamic>> addCompleteResult(
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/results/complete'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) return body;
    throw Exception(body['detail'] ?? 'Failed to save result');
  }

  static Future<Map<String, dynamic>> getTestResult(String testReqId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/results/test_req_id/$testReqId'),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load test result');
  }
  
}
