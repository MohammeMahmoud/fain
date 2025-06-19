class tasks {
  bool? status;
  String? message;
  List<Data>? data;

  tasks({this.status, this.message, this.data});

  tasks.fromJson(Map<String, dynamic> json) {
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
  int? taskID;
  String? title;
  String? description;
  String? deadline;
  String? createdBy;

  Data(
      {this.taskID,
      this.title,
      this.description,
      this.deadline,
      this.createdBy});

  Data.fromJson(Map<String, dynamic> json) {
    taskID = json['TaskID'];
    title = json['Title'];
    description = json['Description'];
    deadline = json['Deadline'];
    createdBy = json['CreatedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TaskID'] = this.taskID;
    data['Title'] = this.title;
    data['Description'] = this.description;
    data['Deadline'] = this.deadline;
    data['CreatedBy'] = this.createdBy;
    return data;
  }
}
