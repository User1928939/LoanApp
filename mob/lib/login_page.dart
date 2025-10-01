import 'package:flutter/material.dart';
import 'routes.dart';
import 'services/service_locator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/UserSession.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _contactController = TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  double _opacity = 0.0;
  double _scale = 0.95;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                child: AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // App name
                      const SizedBox(height: 40),
                      // Welcome text
                      const Text(
                        'Welcome to HedNiya',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Subtitle
                      const Text(
                        'Track informal loans with friends and family effortlessly.',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Phone or email input
                      TextField(
                        controller: _contactController,
                        decoration: InputDecoration(
                          hintText: 'Phone number or email',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_contactController.text.isNotEmpty) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );
                              try {
                                // Make POST request to create user
                                final response = await http.post(
                                  Uri.parse('http://127.0.0.1:8000/users'), // Change to your API endpoint
                                  headers: {'Content-Type': 'application/json'},
                                  body: '{"email": "${_contactController.text}"}',
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                                if (response.statusCode == 201) {
                                  // Navigate to dashboard
                                  final body = jsonDecode(response.body);
                                  // ✅ Save user globally
                                  UserSession.id = body['id'];
                                  UserSession.email = body['email'];
                                  serviceLocator.navigationService.pushAndClearStack(
                                    Routes.dashboard,
                                  );
                                } else {
                                  // Show error message
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to create user: ${response.body}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Terms of service text
                      const Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
