class MaterialItem {
  final String matrialType;
  final String matrialTitle;
  final String? matrialDesc;
  final String showUrl;
  final String downloadUrl;

  MaterialItem({
    required this.matrialType,
    required this.matrialTitle,
    this.matrialDesc,
    required this.showUrl,
    required this.downloadUrl,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      matrialType: json['MatrialType']?.toString() ?? '',
      matrialTitle: json['MatrialTitle'],
      matrialDesc: json['MatrialDesc'],
      showUrl: json['ShowUrl'],
      downloadUrl: json['DownloadUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MatrialType': matrialType,
      'MatrialTitle': matrialTitle,
      'MatrialDesc': matrialDesc,
      'ShowUrl': showUrl,
      'DownloadUrl': downloadUrl,
    };
  }
}
