import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/service_locator.dart';
import '../theme.dart';
import '../routes.dart';
import '../services/UserSession.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId = UserSession.id;

   ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  UserProfile? _userProfile;
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = widget.userId;
      if (userId != null) {
        final userService = ApiUserService();
        _userProfile = await userService.getUserProfile(userId);
        _displayNameController.text = _userProfile?.pseudonym ?? '';
        _emailController.text = _userProfile?.email ?? '';
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
       
      

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.trustBlue,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.trustBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Display name
                  TextField(
                    controller: _displayNameController,
                    decoration: AppTheme.inputDecoration('Display Name'),
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 16),

                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: AppTheme.inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 24),

                  // Phone number (non-editable)
                  if (_userProfile?.phone != null)
                    Text(
                      'Phone: ${_userProfile?.phone ?? "-"}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),


                  // Created date

                  const SizedBox(height: 32),

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: AppTheme.primaryButtonStyle.copyWith(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      child: const Text('Update Profile', style: TextStyle(color: Colors.black)),
                    ),
                  ),

                  const SizedBox(height: 16), // Sign out button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        // Navigate to welcome screen and clear stack
                        UserSession.clear();
                        serviceLocator.navigationService.pushAndClearStack(
                          Routes.welcome,
                        );
                      },
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
