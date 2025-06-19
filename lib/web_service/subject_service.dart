import 'dart:convert';
import 'package:dio/dio.dart';
import '../Models/subject_model.dart';

class SubjectService {
  static final Dio _dio = Dio();

  static Future<List<Data>?> fetchSubjects(String username) async {
    try {
      final url = 'https://apex.oracle.com/pls/apex/fain_app/Subjects/Subjects/';
      final response = await _dio.post(
        url,
        data: {
          'p_user_name': username,
        },
      );

      print('Subject API response status: ${response.statusCode}, body: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;

        if (data.containsKey('Data') && data['Data'] is List) {
          final List<dynamic> items = data['Data'];
          return items.map((item) => Data.fromJson(item)).toList();
        } else {
          print('No data found in response or data is not a list');
          return null;
        }
      } else {
        print('Error in Status Code: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Error fetching subjects: ${e.response?.statusCode} - ${e.message}');
      return null;
    } catch (e) {
      print('Error fetching subjects: $e');
      return null;
    }
  }
} 