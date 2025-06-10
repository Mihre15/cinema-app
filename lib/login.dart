import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin/admin.dart';
import 'nav.dart';
import 'SignUp.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController= TextEditingController();

  

  void _submitLogin() async{
    if (_formKey.currentState!.validate()){
      String email = _emailController.text;
      String password=_passwordController.text;

      var url = Uri.parse('http://10.0.2.2:3000/login');

  try{
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
      
    );
    if(response.statusCode==200){
      var data=jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login successful")),
          );
          Navigator.push(context,
           MaterialPageRoute(builder: (context) => Navigation(),));
    }
    else{
      var errorMessage=jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('invalid email or password'))
      );
    }
  }
  catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network or server error"))
    );
       }
    }
  }
   @override
   Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(16),
          children: [
            Center(
              child: SizedBox(
                width: 300,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color:Color(0XffD59708)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0XffD59708), width: 1.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                   style:TextStyle(color: Color(0XffD59708)),
                   cursorColor:Color(0XffD59708),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null|| !value.contains('@')
                  ? 'Enter valid email'
                  :null,
                ),
              ),
             ),
             SizedBox(height: 25,),
             Center(
              child: SizedBox(
                width: 300,
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Color(0XffD59708)),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0XffD59708)),
                    ),
                    ),
                    style: TextStyle(color: Color(0XffD59708)),
                    cursorColor: Color(0XffD59708),
                   obscureText: true,
                   validator: (value) => value== null||value.length<6
                   ? 'Password must be at least 6 Characters'
                   :null,
                ),
              ),
             ),
             SizedBox(height: 16,),
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
             SizedBox(height: 20,),
             Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: (){
                      Navigator.push(
                        context, MaterialPageRoute(builder:(context)=> SignUpPage() )
                        );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0XffD59708),
                    ),
                    child: Text('sign Up'),
                  ),
                ],
              ),
             ),
             SizedBox(height: 15,),
             Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Log in as admin'),
                  TextButton(onPressed: (){
                   Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>Admin())
                    );
                  }, 
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0XffD59708),
                  ),
                  child: Text('Admin'))
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