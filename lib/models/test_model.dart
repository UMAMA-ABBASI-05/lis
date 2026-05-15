class TestRequestModel {
  final int testReqId;
  final int nic;
  final String testName;
  final String status; // Pending, Accepted, Declined, Completed
  final String? declineReason;
  final int? lockedBy;
  final String? lockedAt;

  TestRequestModel({
    required this.testReqId,
    required this.nic,



    required this.testName,
    required this.status,
    this.declineReason,
    this.lockedBy,
    this.lockedAt,
  });

  /// Create from JSON (API response)
  factory TestRequestModel.fromJson(Map<String, dynamic> json) {
    return TestRequestModel(
      testReqId: json['test_req_id'],
      nic: json['nic'],
      testName: json['test_name'],
      status: json['status'],
      declineReason: json['decline_reason'],
      lockedBy: json['locked_by'],
      lockedAt: json['locked_at'],
    );
  }

  /// Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      'test_req_id': testReqId,
      'nic': nic,
      'test_name': testName,
      'status': status,
      'decline_reason': declineReason,
      'locked_by': lockedBy,
      'locked_at': lockedAt,
    };
  }
}

class MiniLabResultModel {
  final String testName;
  final String normalRange;
  final String resultValue;

  MiniLabResultModel({
    required this.testName,
    required this.normalRange,
    required this.resultValue,
  });

  /// Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      'test_name': testName,
      'normal_range': normalRange,
      'result_value': resultValue,
    };
  }
}

class LabResultModel {
  final int userId;
  final int testReqId;
  final String? description;
  final List<MiniLabResultModel> miniTests;

  LabResultModel({
    required this.userId,
    required this.testReqId,
    this.description,
    required this.miniTests,
  });

  /// Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'test_req_id': testReqId,
      'description': description,
      'mini_tests': miniTests.map((test) => test.toJson()).toList(),
    };
  }
}

class BillingModel {
  final int pid;
  final int testReqId;
  final double billAmount;
  final String paymentStatus;

  BillingModel({
    required this.pid,
    required this.testReqId,
    required this.billAmount,
    required this.paymentStatus,
  });

  /// Create from JSON (API response)
  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
      pid: json['pid'],
      testReqId: json['test_req_id'],
      billAmount: (json['bill_amount'] as num).toDouble(),
      paymentStatus: json['payment_status'],
    );
  }

  /// Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'test_req_id': testReqId,
      'bill_amount': billAmount,
      'payment_status': paymentStatus,
    };
  }
}
