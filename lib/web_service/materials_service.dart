import 'package:dio/dio.dart';
import 'package:nctu/Models/materials_model.dart';
import 'dart:convert';

class MaterialService {
  final Dio _dio = Dio();
  final String _url = 'https://apex.oracle.com/pls/apex/fain_app/Subjects/matrials/';

  Future<List<MaterialItem>> fetchMaterials({
    required String username,
    required String subID,
  }) async {
    try {
      final response = await _dio.post(
        _url,
        data: jsonEncode({
          'p_user_name': username,
          'p_subj_id': subID,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('API Response Status Code: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // Check if response.data is already a Map (Dio might parse it automatically)
        final Map<String, dynamic> data = (response.data is String)
            ? jsonDecode(response.data) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;

        if (data.containsKey('Data') && data['Data'] is List) {
          final List<dynamic> items = data['Data'];
          return items.map((item) => MaterialItem.fromJson(item)).toList();
        } else {
          throw Exception('Invalid data structure in API response.');
        }
      } else {
        throw Exception('Failed to load materials: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch materials: $e');
    }
  }
}
