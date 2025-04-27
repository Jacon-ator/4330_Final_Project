import 'package:flutter/material.dart';
import 'package:final_project_flutter_app/services/auth_service.dart';

class SignUpPage extends StatefulWidget{
  final String name;

  const SignUpPage({super.key, required this.name});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  
  //fields for the entered email and password and an AuthService
  String email = '';
  String password = '';
  AuthService authservice = AuthService();

  void _signup(){
    authservice.signup(email: email, password: password);
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Create an Account"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
              label: Text('Email address'),
              ),
               onChanged: (value){
              email = value;
              },
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
              label: Text('Password'),
              ),
               onChanged: (value){
              password = value;
              },
            ),
            TextButton(onPressed: _signup, child: Text('Sign Up'))
          ],
        ),
      ),
    );
  }
}