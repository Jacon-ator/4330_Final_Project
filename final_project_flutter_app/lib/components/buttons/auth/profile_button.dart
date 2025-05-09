import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/screens/profile_page.dart';
import 'package:flame/widgets.dart'; // Required for SpriteWidget
import 'package:flutter/material.dart';

class ProfileButton extends StatefulWidget {
  final String name;

  const ProfileButton({super.key, required this.name});

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  final SFXManager _sfxManager =
      SFXManager(); // Consider how this is managed if it's a game-wide service
  Sprite? _profileSprite;
  bool _isLoadingSprite = true;

  @override
  void initState() {
    super.initState();
    _loadProfileSprite();
  }

  Future<void> _loadProfileSprite() async {
    try {
      const String spritePath = 'art/Profile Image.png';
      final loadedSprite = await Sprite.load(spritePath);
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _profileSprite = loadedSprite;
          _isLoadingSprite = false;
        });
      }
    } catch (e) {
      print('Error loading profile sprite: $e');
      if (mounted) {
        setState(() {
          _isLoadingSprite = false; // Stop loading, even if there's an error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _sfxManager.playButtonSelect();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokerProfilePage(name: widget.name),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(0, 196, 122, 122), // white circular background
        ),
        child: _isLoadingSprite
            ? const SizedBox(
                width: 32, // Match original Icon size
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : _profileSprite != null
                ? SpriteWidget(
                    sprite: _profileSprite!,
                  )
                : const Icon(
                    // Fallback icon if sprite fails to load
                    Icons.person, // Or Icons.error
                    size: 32,
                    color: Colors.black,
                  ),
      ),
    );
  }
}
