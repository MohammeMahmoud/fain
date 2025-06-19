import 'dart:convert';
import 'package:dio/dio.dart';
import '../Models/task_model.dart';
import '../provider/auth_provider.dart';

class TaskService {
  static final Dio _dio = Dio();

  static Future<List<Data>?> fetchTasks(String username) async {
    try {
      final url = 'https://apex.oracle.com/pls/apex/fain_app/Subjects/tasks/';
      final response = await _dio.post(
        url,
        data: {
          'p_user_name': username,
        },
      );

      print('Task API response status: ${response.statusCode}, body: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data['Status'] == true && data['Data'] != null) {
          final List<dynamic> tasksData = data['Data'];
          return tasksData.map((task) => Data.fromJson(task)).toList();
        }
      }
      return null;
    } on DioException catch (e) {
      print('Error fetching tasks: ${e.response?.statusCode} - ${e.message}');
      return null;
    } catch (e) {
      print('Error fetching tasks: $e');
      return null;
    }
  }
} 