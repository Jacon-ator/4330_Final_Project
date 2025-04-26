import 'package:final_project_flutter_app/widgets/profile_page.dart';
import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final String name;

  const ProfileButton({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokerProfilePage(name: name),
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
          Icons.person,
          size: 32, // size of the icon
          color: Colors.black, // icon color
        ),
      ),
    );
  }
}
