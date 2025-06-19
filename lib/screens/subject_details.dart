import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/subject_model.dart';
import '../web_service/materials_service.dart';
import '../provider/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import '../Models/materials_model.dart'; // Added import for MaterialItem

class SubjectDetailsPage extends StatefulWidget {
  final Data subject;

  const SubjectDetailsPage({Key? key, required this.subject}) : super(key: key);

  @override
  State<SubjectDetailsPage> createState() => _SubjectDetailsPageState();
}

class _SubjectDetailsPageState extends State<SubjectDetailsPage> {
  List<MaterialItem> _allMaterials = [];
  List<MaterialItem> lectures = [];
  List<MaterialItem> sections = [];
  bool isLoading = true;
  String? _errorMessage;

  // Instantiate the service
  final MaterialService _materialService = MaterialService();

  @override
  void initState() {
    super.initState();
    _errorMessage = null;
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
      _allMaterials = [];
      lectures = [];
      sections = [];
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        setState(() {
          _errorMessage = 'User not authenticated. Please log in.';
          isLoading = false;
        });
        return;
      }

      final username = authProvider.user!.username;
      if (username == null) {
        setState(() {
          _errorMessage = 'Username not found for the authenticated user.';
          isLoading = false;
        });
        return;
      }

      final subjectId = widget.subject.sUBJECTID?.toString() ?? '';
      if (subjectId.isEmpty) {
        setState(() {
          _errorMessage = 'Subject ID is missing.';
          isLoading = false;
        });
        return;
      }
      
      print('Attempting to fetch materials for Username: $username and Subject ID: $subjectId');

      final fetchedMaterials = await _materialService.fetchMaterials(
        username: username,
        subID: subjectId,
      );

      if (fetchedMaterials.isEmpty) {
        setState(() {
          _errorMessage = 'No lectures or sections found for this subject.';
          isLoading = false;
        });
        print('MaterialService.fetchMaterials returned empty list.');
      } else {
        _allMaterials = fetchedMaterials;
        lectures = _allMaterials.where((MaterialItem item) {
          print('Material Type received: ${item.matrialType}'); // For debugging
          return item.matrialType.trim().toLowerCase() == 'lecture';
        }).toList();
        sections = _allMaterials.where((MaterialItem item) {
          print('Material Type received: ${item.matrialType}'); // For debugging
          return item.matrialType.trim().toLowerCase() == 'section';
        }).toList();

        setState(() {
          isLoading = false;
        });
        print('Successfully loaded ${fetchedMaterials.length} materials.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        isLoading = false;
      });
      print('Error fetching materials for subject: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No URL provided for this material.')),
      );
      return;
    }
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.sUBJNAME ?? 'Subject Details'),
      ),
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
                          onPressed: _fetchMaterials,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lectures Section
                        if (lectures.isNotEmpty)
                          Text(
                            'Lectures',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        if (lectures.isNotEmpty) const SizedBox(height: 10),
                        if (lectures.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: lectures.length,
                            itemBuilder: (context, index) {
                              final lecture = lectures[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(lecture.matrialTitle ?? 'No Title'),
                                  subtitle: Text(lecture.matrialDesc ?? 'No Description'),
                                  trailing: Icon(Icons.picture_as_pdf), // Or appropriate icon
                                  onTap: () {
                                    _launchURL(lecture.showUrl);
                                  },
                                ),
                              );
                            },
                          ),

                        if (lectures.isNotEmpty && sections.isNotEmpty) const SizedBox(height: 20),

                        // Sections Section
                        if (sections.isNotEmpty)
                          Text(
                            'Sections',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        if (sections.isNotEmpty) const SizedBox(height: 10),
                        if (sections.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sections.length,
                            itemBuilder: (context, index) {
                              final section = sections[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(section.matrialTitle ?? 'No Title'),
                                  subtitle: Text(section.matrialDesc ?? 'No Description'),
                                  trailing: Icon(Icons.article), // Or appropriate icon
                                  onTap: () {
                                    _launchURL(section.showUrl);
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
} 