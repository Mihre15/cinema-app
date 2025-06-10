import 'package:flutter/material.dart';
import 'package:pra/Home.dart';
import 'package:pra/SignUp.dart';
import 'package:pra/models/user_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserAuthWrapper extends StatefulWidget {
  const UserAuthWrapper({super.key});

  @override
  State<UserAuthWrapper> createState() => _UserAuthWrapperState();
}

class _UserAuthWrapperState extends State<UserAuthWrapper> {
  bool _isLoading = true;
  UserState? _userState;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      
      if (authToken == null) {
        setState(() {
          _userState = UserState.empty();
          _isLoading = false;
        });
        return;
      }

      final response = await dio.get(
        "/current-user",
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );
      
      debugPrint('User data: ${response.data}');

      if (response.statusCode == 200 && response.data["isLoggedIn"] == true) {
        // Save user data to shared preferences
        await prefs.setString('user_data', jsonEncode(response.data));
        
        setState(() {
          _userState = UserState.fromJson(response.data);
        });
      } else {
        setState(() {
          _userState = UserState.empty();
        });
      }
    } catch (e) {
      debugPrint("Session check error: $e");
      setState(() {
        _userState = UserState.empty();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _userState?.isLoggedIn == true
        ? Home(userState: _userState!)
        : const SignUpPage();
  }
}