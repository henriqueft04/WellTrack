import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/main_navigation.dart';
import 'package:welltrack/models/profile_button.dart';
import 'package:welltrack/providers/user_provider.dart';
import 'package:welltrack/services/image_upload_service.dart';
import 'package:welltrack/main.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize name controller with current user name
    final userProfile = context.read<UserProvider>().userProfile;
    _nameController.text = userProfile?['name'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfileImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Store all context-dependent references at the very beginning
      final messenger = ScaffoldMessenger.of(context);
      final userProvider = context.read<UserProvider>();
      
      setState(() {
        _isLoading = true;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        // Get current user ID
        final currentUser = supabase.auth.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Upload image to Supabase Storage
        final imageUrl = await ImageUploadService().uploadImage(
          File(pickedFile.path),
          currentUser.id,
        );
        
        if (imageUrl != null) {
          final success = await userProvider.updateUserAvatar(imageUrl);
          
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(success ? 'Profile image updated successfully!' : 'Failed to update profile image'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        } else {
          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Failed to upload image. Please check your internet connection and try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateName() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context);
                  
                  setState(() {
                    _isLoading = true;
                  });

                  // Store reference before async call
                  final userProvider = context.read<UserProvider>();
                  final messenger = ScaffoldMessenger.of(context);
                  final success = await userProvider.updateUserName(newName);
                  
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Name updated successfully!' : 'Failed to update name'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return NonMainPageWrapper(
      originIndex: 4,
      child: AppLayout(
        pageTitle: 'Edit Profile',
        showLogo: false,
        isMainPage: false,
        showBackButton: true,
        content: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Image Section
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final userProfile = userProvider.userProfile;
                      final avatarUrl = userProfile?['avatar'];
                      
                      // Check if avatar URL is valid and not a placeholder
                      bool hasValidAvatar = avatarUrl != null && 
                                           avatarUrl.isNotEmpty && 
                                           !avatarUrl.contains('placeholder.com') &&
                                           !avatarUrl.contains('via.placeholder');
                      
                      return Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: hasValidAvatar
                                    ? NetworkImage(avatarUrl)
                                    : const AssetImage('lib/images/profile_photo.png') as ImageProvider,
                                onBackgroundImageError: hasValidAvatar ? (exception, stackTrace) {
                                  // Handle network image loading errors gracefully
                                  debugPrint('Error loading avatar image: $exception');
                                } : null,
                                child: !hasValidAvatar
                                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                    onPressed: _updateProfileImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userProfile?['name'] ?? 'No Name Found',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            userProfile?['email'] ?? 'No Email Found',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Edit Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        ProfileButton(
                          icon: Icons.edit,
                          text: 'Edit Name',
                          onTap: _updateName,
                        ),
                        ProfileButton(
                          icon: Icons.image,
                          text: 'Change Profile Picture',
                          onTap: _updateProfileImage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
