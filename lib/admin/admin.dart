
import 'package:flutter/material.dart';
import 'package:pra/Home.dart';
import 'package:http/http.dart' as http;
import 'package:pra/models/user_state.dart';
import 'dart:convert';
import 'admin-nav.dart';
import 'package:pra/nav.dart';

void main() {
  runApp(MaterialApp(
    home: Admin(),
    debugShowCheckedModeBanner: false,
  ));
}

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  _Admin createState() => _Admin();
}

class _Admin extends State<Admin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      var url = Uri.parse('http://10.0.2.2:3000/admin/login'); // Use 10.0.2.2 for emulator if needed

      try {
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login successful")),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Nav()),
          );
        } else {
          var errorMessage = jsonDecode(response.body)['message'] ?? 'Login failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network or server error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 50, 40, 30),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(16),
            children: [
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 70,
                ),
              ),
              SizedBox(height: 35),
              Center(
                child: SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Color(0XffD59708)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0XffD59708)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    style: TextStyle(color: Color(0XffD59708)),
                    cursorColor: Color(0XffD59708),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value == null || !value.contains('@')
                            ? 'Enter a valid email'
                            : null,
                  ),
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color(0XffD59708)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0XffD59708)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    style: TextStyle(color: Color(0XffD59708)),
                    cursorColor: Color(0XffD59708),
                    obscureText: true,
                    validator: (value) =>
                        value == null || value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                  ),
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _submitLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XffD59708),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Login'),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Go to Home Page'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Navigation()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0XffD59708),
                      ),
                      child: Text('HomePage'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
