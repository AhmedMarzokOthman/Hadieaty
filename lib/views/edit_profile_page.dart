import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  File? _selectedImage;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? _imageUrl;
  bool _hasChangedUsername = false;
  bool _usernameAvailable = true;
  final UserController _userController = UserController();
  bool _isProfilePictureLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _usernameController = TextEditingController(text: widget.user.username);
    _imageUrl = widget.user.profilePicture;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<bool> _pickImageFromGallery() async {
    try {
      final returnedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (returnedImage == null) return false;

      setState(() {
        _selectedImage = File(returnedImage.path);
        _isProfilePictureLoading = true;
      });

      // Add timeout handling
      bool uploadSuccess = false;
      try {
        await _uploadImageToCloudinary().timeout(
          Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Image upload timed out');
          },
        );
        uploadSuccess = true;
      } catch (e) {
        setState(() {
          _isProfilePictureLoading = false;
          _selectedImage = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload timed out. Please try again.')),
          );
        }
      }

      return uploadSuccess;
    } catch (e) {
      log('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
      }
      setState(() {
        _isProfilePictureLoading = false;
      });
      return false;
    }
  }

  Future<void> _uploadImageToCloudinary() async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/imigicloud/upload",
      );

      final request =
          http.MultipartRequest("POST", url)
            ..fields["upload_preset"] = "hadieaty_preset"
            ..files.add(
              await http.MultipartFile.fromPath("file", _selectedImage!.path),
            );

      final response = await request.send();

      if (response.statusCode == 200) {
        final resData = await response.stream.toBytes();
        final resString = String.fromCharCodes(resData);
        final jsonMap = jsonDecode(resString);

        setState(() {
          _imageUrl = jsonMap["url"];
          _isProfilePictureLoading = false;
        });
      } else {
        throw Exception(
          'Failed to upload image. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
      setState(() {
        _selectedImage = null;
        _isProfilePictureLoading = false;
      });
    }
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (!_hasChangedUsername || username == widget.user.username) {
      setState(() {
        _usernameAvailable = true;
      });
      return;
    }

    try {
      final user = await _userController.getUserByUsername(username);
      setState(() {
        _usernameAvailable = user == null;
      });
    } catch (e) {
      log('Error checking username: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Create updated user model
      final updatedUser = UserModel(
        uid: widget.user.uid,
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: widget.user.email,
        profilePicture: _imageUrl,
      );

      // log('Updating user profile: ${updatedUser.toJson()}');

      // First update in Hive local storage
      await _userController.saveUserToLocal(updatedUser);

      // Then update in Firestore
      await _userController.updateUserProfile(updatedUser);

      // Update in friends collections
      final friends = await _userController.getFriends();
      for (final friend in friends) {
        try {
          await _userController.updateFriendReference(friend.uid, updatedUser);
        } catch (e) {
          log('Error updating friend reference: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      log('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFAB5D), Color(0xFFFB6938)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFFFB6938), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child:
                            _isProfilePictureLoading
                                ? Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFB6938),
                                  ),
                                )
                                : _selectedImage != null
                                ? Image.file(
                                  _selectedImage!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                                : _imageUrl != null && _imageUrl!.isNotEmpty
                                ? Image.network(
                                  _imageUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    log('Error loading profile image: $error');
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[600],
                                  ),
                                ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImageFromGallery,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFFB6938),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFB6938)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.alternate_email),
                  suffixIcon:
                      _usernameController.text != widget.user.username
                          ? _usernameAvailable
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : Icon(Icons.error, color: Colors.red)
                          : null,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFB6938)),
                  ),
                  helperText:
                      _usernameController.text != widget.user.username &&
                              !_usernameAvailable
                          ? 'Username already taken'
                          : null,
                  helperStyle: TextStyle(color: Colors.red),
                ),
                onChanged: (value) {
                  setState(() {
                    _hasChangedUsername = value != widget.user.username;
                  });
                  _checkUsernameAvailability(value);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (!_usernameAvailable) {
                    return 'Username is already taken';
                  }
                  if (value.contains(' ')) {
                    return 'Username cannot contain spaces';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Email Field (disabled)
              TextFormField(
                initialValue: widget.user.email,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isProfilePictureLoading || _isLoading
                          ? null
                          : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isProfilePictureLoading || _isLoading
                            ? Colors.grey
                            : Color(0xFFFB6938),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isProfilePictureLoading
                        ? 'UPLOADING PICTURE...'
                        : 'SAVE CHANGES',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
