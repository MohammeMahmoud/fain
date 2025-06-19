class SubjectModel {
  bool? status;
  String? message;
  List<Data>? data;

  SubjectModel({this.status, this.message, this.data});

  SubjectModel.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    message = json['Message'];
    if (json['Data'] != null) {
      data = <Data>[];
      json['Data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['Message'] = this.message;
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sUBJNAME;
  int? sUBJHOURS;
  String? pROF;
  int? sUBJECTID;
  int? mATERIALSCOUNT;

  Data(
      {this.sUBJNAME,
      this.sUBJHOURS,
      this.pROF,
      this.sUBJECTID,
      this.mATERIALSCOUNT});

  Data.fromJson(Map<String, dynamic> json) {
    sUBJNAME = json['SUBJ_NAME'];
    sUBJHOURS = json['SUBJ_HOURS'];
    pROF = json['PROF'];
    sUBJECTID = json['SUBJECT_ID'];
    mATERIALSCOUNT = json['MATERIALS_COUNT'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SUBJ_NAME'] = this.sUBJNAME;
    data['SUBJ_HOURS'] = this.sUBJHOURS;
    data['PROF'] = this.pROF;
    data['SUBJECT_ID'] = this.sUBJECTID;
    data['MATERIALS_COUNT'] = this.mATERIALSCOUNT;
    return data;
  }
}
