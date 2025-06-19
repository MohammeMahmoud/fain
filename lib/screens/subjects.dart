import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import '../Models/subject_model.dart';
import '../web_service/subject_service.dart';
import '../provider/auth_provider.dart';
import '../screens/subject_details.dart';

class SubjectsPage extends StatefulWidget {
  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  List<Data> subjects = [];
  bool isLoading = true;
  Map<String, double> downloadProgress = {};
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _errorMessage = null;
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        setState(() {
          _errorMessage = 'User not authenticated. Please log in.';
          isLoading = false;
        });
        print('Error: User not authenticated in SubjectsPage.');
        return;
      }

      final username = authProvider.user!.username;
      if (username == null) {
        setState(() {
          _errorMessage = 'Username not found for the authenticated user.';
          isLoading = false;
        });
        print('Error: Username is null for authenticated user in SubjectsPage.');
        return;
      }
      print('Fetching subjects for username: $username');

      final fetchedSubjects = await SubjectService.fetchSubjects(username);
      if (fetchedSubjects == null) {
        setState(() {
          _errorMessage = 'Failed to load subjects. Please try again later.';
          isLoading = false;
        });
        print('SubjectService.fetchSubjects returned null for username: $username');
      } else if (fetchedSubjects.isEmpty) {
        setState(() {
          subjects = [];
          _errorMessage = 'No subjects found for this user.';
          isLoading = false;
        });
        print('SubjectService.fetchSubjects returned empty list for username: $username');
      } else {
        setState(() {
          subjects = fetchedSubjects;
          isLoading = false;
        });
        print('Successfully loaded ${fetchedSubjects.length} subjects.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        isLoading = false;
      });
      print('Error fetching subjects in SubjectsPage: $e');
    }
  }

  void showDownloadDialog(Data subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download Material'),
        content: Text('Do you want to download "${subject.sUBJNAME}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Download is not supported with current data model')),
              );
            },
            child: Text('Download'),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return true; // iOS doesn't need these permissions

    final androidInfo = await deviceInfo.androidInfo;
    final androidVersion = androidInfo.version.sdkInt;

    if (androidVersion >= 33) {
      final status = await Permission.notification.request();
      return true;
    }
    else if (androidVersion >= 30) {
      if (!await Permission.manageExternalStorage.isGranted) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('For downloading files, you need to grant storage permission'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
              duration: Duration(seconds: 5),
            ),
          );
          return false;
        }
      }
      return true;
    }
    else {
      if (!await Permission.storage.isGranted) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
      return true;
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    Directory? directory;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final androidVersion = androidInfo.version.sdkInt;

        if (androidVersion >= 30) {
          directory = await getExternalStorageDirectory();
        } else {
          try {
            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              directory = await getExternalStorageDirectory();
            }
          } catch (e) {
            directory = await getExternalStorageDirectory();
          }
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      return directory;
    } catch (e) {
      print('Error getting download directory: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 50),
                        SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: fetchData,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : subjects.isEmpty
                  ? Center(child: Text('No Subjects Found'))
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubjectDetailsPage(subject: subject),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subject.sUBJNAME?.toString() ?? 'Unknown Subject',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 18, color: Colors.grey[700]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${subject.pROF ?? 'Unknown'}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (subject.sUBJHOURS != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.hourglass_empty, size: 18, color: Colors.grey[700]),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Credit Hours: ${subject.sUBJHOURS}',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (subject.mATERIALSCOUNT != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.insert_drive_file, size: 18, color: Colors.grey[700]),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Materials: ${subject.mATERIALSCOUNT}',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}