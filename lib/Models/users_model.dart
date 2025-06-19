class UserResponse {
  Data? data;
  bool? status;
  String? message;

  UserResponse({this.data, this.status, this.message});

  UserResponse.fromJson(Map<String, dynamic> json) {
    data = json['Data'] != null ? new Data.fromJson(json['Data']) : null;
    status = json['Status'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    data['Status'] = this.status;
    data['Message'] = this.message;
    return data;
  }
}

class Data {
  int? studentCode;
  String? username;
  String? name;
  String? email;
  int? sectionId;
  String? departmentName;
  String? gender;
  String? acadimicYear;
  String? profilePicturePath;

  Data(
      {this.studentCode,
      this.username,
      this.name,
      this.email,
      this.sectionId,
      this.departmentName,
      this.gender,
      this.acadimicYear,
      this.profilePicturePath});

  Data.fromJson(Map<String, dynamic> json) {
    studentCode = json['studentCode'];
    username = json['username'];
    name = json['name'];
    email = json['email'];
    sectionId = json['sectionId'];
    departmentName = json['DepartmentName'];
    gender = json['Gender'];
    acadimicYear = json['AcadimicYear'];
    profilePicturePath = json['profilePicturePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['studentCode'] = this.studentCode;
    data['username'] = this.username;
    data['name'] = this.name;
    data['email'] = this.email;
    data['sectionId'] = this.sectionId;
    data['DepartmentName'] = this.departmentName;
    data['Gender'] = this.gender;
    data['AcadimicYear'] = this.acadimicYear;
    data['profilePicturePath'] = this.profilePicturePath;
    return data;
  }
}
