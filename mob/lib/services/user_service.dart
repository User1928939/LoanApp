import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_profile.dart';

abstract class UserService {
  Future<UserProfile> getUserProfile(int userId);
}

class ApiUserService implements UserService {
  @override
  Future<UserProfile> getUserProfile(int userId) async {
    final url = Uri.parse('http://localhost:8000/users/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }
}
