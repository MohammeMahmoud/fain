import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nctu/provider/auth_provider.dart';
import 'package:nctu/screens/login.dart';
import 'package:nctu/services/profile_picture_service.dart';

import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  bool _isLoadingImage = false;
  bool _isSavingImage = false;

  @override
  void initState() {
    super.initState();
    _loadSavedProfilePicture();
  }

  Future<void> _loadSavedProfilePicture() async {
    setState(() {
      _isLoadingImage = true;
    });

    try {
      final savedImage = await ProfilePictureService.loadProfilePicture();
      if (savedImage != null) {
        setState(() {
          _imageFile = savedImage;
        });
        print('Saved profile picture loaded successfully');
      }
    } catch (e) {
      print('Error loading saved profile picture: $e');
    } finally {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (picked != null) {
        setState(() {
          _isSavingImage = true;
        });

        final imageFile = File(picked.path);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.saveProfilePicture(imageFile);

        if (success) {
          setState(() {
            _imageFile = imageFile;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture saved successfully! 📸'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save profile picture. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isSavingImage = false;
      });
    }
  }

  Future<void> _removeProfilePicture() async {
    try {
      setState(() {
        _isSavingImage = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.deleteProfilePicture();

      if (success) {
        setState(() {
          _imageFile = null;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture removed successfully'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove profile picture'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error removing profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isSavingImage = false;
      });
    }
  }

  Future<void> _showImageOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            if (_imageFile != null) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Picture', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await auth.logout();
      if (!mounted) return;
      
      // Navigate to login screen and clear all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final size = MediaQuery.of(context).size;
    final avatarRadius = size.width * 0.18;
    final headerPaddingTop = size.height * 0.07;
    final headerPaddingBottom = size.height * 0.025;
    final cardPadding = size.width * 0.06;
    final cardVertical = size.height * 0.025;
    final spacing = size.height * 0.02;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue header with avatar and settings
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: headerPaddingTop, bottom: headerPaddingBottom),
              decoration: const BoxDecoration(
                color: Color(0xFF2563FF),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _isSavingImage ? null : _showImageOptions,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: Colors.white,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (user?.email != null
                                      ? NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.name ?? "User")}&background=2563FF&color=fff')
                                      : null) as ImageProvider?,
                              child: _isLoadingImage
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : _imageFile == null && user?.email == null
                                      ? const Icon(Icons.person, size: 48, color: Colors.grey)
                                      : null,
                            ),
                            if (!_isSavingImage && !_isLoadingImage)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: _isSavingImage
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563FF)),
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt, size: 18, color: Color(0xFF2563FF)),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing),
                      Center(
                        child: Text(
                          user?.name ?? 'User Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 0.2),
                      Center(
                        child: Text(
                         ' ${user?.departmentName}' ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      // TODO: Navigate to settings
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing),
            // Card with user info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: cardPadding),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: cardVertical, horizontal: cardPadding * 0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Student ID',
                        value: user?.studentCode.toString() ?? '-',
                      ),
                      SizedBox(height: spacing),
                      _ProfileInfoRow(
                        icon: Icons.account_balance_outlined,
                        label: 'Department',
                        value: '${user?.departmentName}' ?? '*****',
                        bold: true,
                      ),
                      SizedBox(height: spacing),
                      _ProfileInfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Academic Year',
                        value: '${user?.acadimicYear}',
                        bold: true,
                      ),
                      SizedBox(height: spacing),
                      _ProfileInfoRow(
                        icon: Icons.male_outlined,
                        label: 'Gender',
                        value: '${user?.gender}',
                      ),
                      SizedBox(height: spacing),
                      _ProfileInfoRow(
                        icon: Icons.alternate_email,
                        label: 'E-mail',
                        value: user?.email ?? '-',
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing),
            // Logout button
            Padding(
              padding: EdgeInsets.all(cardPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleLogout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool bold;
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.bold = false,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black54, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: bold ? Colors.black : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 