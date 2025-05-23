import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/screens/signup_page.dart';
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String name;
  final SFXManager _sfxManager = SFXManager();

  LoginButton({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _sfxManager.playButtonSelect();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(name: name),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white, // white circular background
        ),
        child: const Icon(
          Icons.login,
          size: 32, // size of the icon
          color: Colors.black, // icon color
        ),
      ),
    );
  }
}
