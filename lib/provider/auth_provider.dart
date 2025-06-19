import 'package:flutter/material.dart';
import 'package:nctu/Models/users_model.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:nctu/services/preferences_service.dart';
import 'package:nctu/services/profile_picture_service.dart';
import 'dart:io';


class AuthProvider with ChangeNotifier {
  Data? _user;
  String? _error;
  bool _loading = false;
  bool _isInitialized = false;
  final Dio _dio = Dio();

  Data? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    try {
      await PreferencesService.init();
      await _loadUserFromStorage();
      await _loadProfilePicture();
      _isInitialized = true;
      notifyListeners();
      print('Successfully initialized SharedPreferences');
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
      _error = 'Failed to initialize storage';
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final userJson = PreferencesService.getUserData();
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _user = Data.fromJson(userMap);
        print('Successfully loaded user from storage: ${_user?.username}');
        notifyListeners();
      } else {
        print('No user data found in storage.');
      }
    } catch (e) {
      print('Failed to load user data from storage: $e');
      _error = 'Failed to load user data';
      notifyListeners();
    }
  }

  Future<void> _loadProfilePicture() async {
    try {
      if (_user != null) {
        final profilePicturePath = await ProfilePictureService.getProfilePicturePath();
        if (profilePicturePath != null) {
          _user!.profilePicturePath = profilePicturePath;
          print('Profile picture path loaded: $profilePicturePath');
        }
      }
    } catch (e) {
      print('Failed to load profile picture: $e');
    }
  }

  Future<void> _saveUserToStorage(Data user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      final success = await PreferencesService.saveUserData(userJson);
      if (success) {
        print('Successfully saved user data to storage: ${user.username}');
      } else {
        print('Failed to save user data to storage');
        _error = 'Failed to save user data';
        notifyListeners();
      }
    } catch (e) {
      print('Failed to save user data to storage: $e');
      _error = 'Failed to save user data';
      notifyListeners();
    }
  }

  Future<void> _clearUserStorage() async {
    try {
      final success = await PreferencesService.removePreference('currentUser');
      if (success) {
        print('User data cleared from storage.');
      } else {
        print('Failed to clear user data from storage');
        _error = 'Failed to clear user data';
        notifyListeners();
      }
    } catch (e) {
      print('Failed to clear user data from storage: $e');
      _error = 'Failed to clear user data';
      notifyListeners();
    }
  }

  /// Save profile picture and update user data
  Future<bool> saveProfilePicture(File imageFile) async {
    try {
      final success = await ProfilePictureService.saveProfilePicture(imageFile);
      if (success && _user != null) {
        final profilePicturePath = await ProfilePictureService.getProfilePicturePath();
        _user!.profilePicturePath = profilePicturePath;
        await _saveUserToStorage(_user!);
        notifyListeners();
        print('Profile picture saved successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error saving profile picture: $e');
      _error = 'Failed to save profile picture';
      notifyListeners();
      return false;
    }
  }

  /// Delete profile picture and update user data
  Future<bool> deleteProfilePicture() async {
    try {
      final success = await ProfilePictureService.deleteProfilePicture();
      if (success && _user != null) {
        _user!.profilePicturePath = null;
        await _saveUserToStorage(_user!);
        notifyListeners();
        print('Profile picture deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting profile picture: $e');
      _error = 'Failed to delete profile picture';
      notifyListeners();
      return false;
    }
  }

  /// Check if user has a profile picture
  Future<bool> hasProfilePicture() async {
    return await ProfilePictureService.hasProfilePicture();
  }

  Future<bool> login(String username, String password) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      if (username.trim().isEmpty) throw 'Username cannot be empty';
      if (password.trim().isEmpty) throw 'Password cannot be empty';

      print('Sending login request for: "$username" / "$password"');

      final response = await _dio.post(
        'https://apex.oracle.com/pls/apex/fain_app/USERS/login/',
        data: {
          'p_user_name': username.trim(),
          'p_password': password.trim(),
        },
      );

      print('Login API response status: ${response.statusCode}, body: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['Status'] == true && data['Data'] != null) {
          _user = Data.fromJson(data['Data']);
          await _saveUserToStorage(_user!);
          notifyListeners();
          return true;
        } else {
          throw data['Message'] ?? 'Invalid username or password';
        }
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _error = e.response?.data['Message'] ?? e.message ?? 'An unknown error occurred';
      print('Login error: $_error');
      return false;
    } catch (e) {
      _error = e.toString();
      print('Login error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _loading = true;
      notifyListeners();

      await _clearUserStorage();
      _user = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to logout';
      print('Logout error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signup({
    required String username,
    required String password,
    required String grade,
    required String section,
    required String code,
    required String gender,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      if (username.trim().isEmpty) throw 'Username cannot be empty';
      if (password.trim().isEmpty) throw 'Password cannot be empty';
      if (grade.trim().isEmpty) throw 'Grade cannot be empty';
      if (section.trim().isEmpty) throw 'Section cannot be empty';
      if (code.trim().isEmpty) throw 'Code cannot be empty';
      if (gender.trim().isEmpty) throw 'Gender cannot be empty';

      print('Sending signup request for: "$username"');

      final response = await _dio.post(
        'https://apex.oracle.com/pls/apex/fain_app/USERS/register/',
        data: {
          'p_user_name': username.trim(),
          'p_password': password.trim(),
          'p_grade': grade.trim(),
          'p_section': section.trim(),
          'p_code': code.trim(),
          'p_gender': gender.trim(),
        },
      );

      print('Signup API response status: ${response.statusCode}, body: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['Status'] == true || data['status'] == true) {
          // After successful registration, automatically log in the user
          return await login(username, password);
        } else {
          throw data['Message'] ?? data['message'] ?? 'Registration failed';
        }
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _error = e.response?.data['Message'] ?? e.message ?? 'An unknown error occurred';
      print('Signup error: $_error');
      return false;
    } catch (e) {
      _error = e.toString();
      print('Signup error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
