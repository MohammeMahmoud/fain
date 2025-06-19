import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class ProfilePictureService {
  static const String _profilePictureKey = 'profile_picture_path';
  static const String _profilePictureFileName = 'profile_picture.jpg';

  /// Save profile picture to local storage
  static Future<bool> saveProfilePicture(File imageFile) async {
    try {
      // Get the app's documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String profilePicturesDir = '${appDir.path}/profile_pictures';
      
      // Create directory if it doesn't exist
      final Directory dir = Directory(profilePicturesDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Compress and save the image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);
      
      if (originalImage == null) {
        print('Failed to decode image');
        return false;
      }

      // Resize image to reasonable dimensions (300x300)
      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: 300,
        height: 300,
        interpolation: img.Interpolation.linear,
      );

      // Save as JPEG with quality 85
      final String filePath = '$profilePicturesDir/$_profilePictureFileName';
      final File savedFile = File(filePath);
      final Uint8List compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      await savedFile.writeAsBytes(compressedBytes);

      // Save the file path to SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profilePictureKey, filePath);

      print('Profile picture saved successfully: $filePath');
      return true;
    } catch (e) {
      print('Error saving profile picture: $e');
      return false;
    }
  }

  /// Load profile picture from local storage
  static Future<File?> loadProfilePicture() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? filePath = prefs.getString(_profilePictureKey);
      
      if (filePath == null) {
        print('No profile picture path found');
        return null;
      }

      final File imageFile = File(filePath);
      if (await imageFile.exists()) {
        print('Profile picture loaded successfully: $filePath');
        return imageFile;
      } else {
        print('Profile picture file not found: $filePath');
        // Remove invalid path from preferences
        await prefs.remove(_profilePictureKey);
        return null;
      }
    } catch (e) {
      print('Error loading profile picture: $e');
      return null;
    }
  }

  /// Delete profile picture from local storage
  static Future<bool> deleteProfilePicture() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? filePath = prefs.getString(_profilePictureKey);
      
      if (filePath != null) {
        final File imageFile = File(filePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
      
      await prefs.remove(_profilePictureKey);
      print('Profile picture deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting profile picture: $e');
      return false;
    }
  }

  /// Check if profile picture exists
  static Future<bool> hasProfilePicture() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? filePath = prefs.getString(_profilePictureKey);
      
      if (filePath == null) return false;
      
      final File imageFile = File(filePath);
      return await imageFile.exists();
    } catch (e) {
      print('Error checking profile picture: $e');
      return false;
    }
  }

  /// Get profile picture file path
  static Future<String?> getProfilePicturePath() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_profilePictureKey);
    } catch (e) {
      print('Error getting profile picture path: $e');
      return null;
    }
  }
} 