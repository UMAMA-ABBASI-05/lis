class PatientModel {
  final int nic;
  final String fname;
  final String? lname;
  final String? dob;
  final String gender;

  PatientModel({
    required this.nic,
    required this.fname,
    this.lname,
    this.dob,
    required this.gender,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      nic: json['nic'],
      fname: json['fname'],
      lname: json['lname'],
      dob: json['dob'],
      gender: json['gender'],
    );
  }
}
