class PatientModel {
  final int mpi;
  final String fname;
  final String? lname;
  final String? dob;
  final String gender;

  PatientModel({
    required this.mpi,
    required this.fname,
    this.lname,
    this.dob,
    required this.gender,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      mpi: json['mpi'],
      fname: json['fname'],
      lname: json['lname'],
      dob: json['dob'],
      gender: json['gender'],
    );
  }
}
