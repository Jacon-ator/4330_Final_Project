import 'package:final_project_flutter_app/screens/chat_list_page.dart';
import 'package:flame/widgets.dart'; // Required for SpriteWidget
import 'package:flutter/material.dart';

class ChatButton extends StatefulWidget {
  final String name;

  const ChatButton({super.key, required this.name});

  @override
  State<ChatButton> createState() => _ChatButtonState();
}

class _ChatButtonState extends State<ChatButton> {
  Sprite? _chatSprite;
  bool _isLoadingSprite = true;

  @override
  void initState() {
    super.initState();
    _loadChatSprite();
  }

  Future<void> _loadChatSprite() async {
    try {
      // IMPORTANT: Replace 'your_chat_sprite_asset_path.png' with the actual path to your sprite image.
      // Example: 'images/chat_icon.png'
      // Ensure this asset is declared in your pubspec.yaml file under flutter > assets.
      const String spritePath = 'art/Chat Button.png'; // <<< CHANGE THIS PATH
      final loadedSprite = await Sprite.load(spritePath);
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _chatSprite = loadedSprite;
          _isLoadingSprite = false;
        });
      }
    } catch (e) {
      print('Error loading chat sprite: $e');
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
        // Consider adding SFXManager.playButtonSelect(); here if you have one for chat button
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatListPage(name: widget.name), // Use widget.name
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(0, 78, 61, 61), // white circular background
        ),
        child: _isLoadingSprite
            ? const SizedBox(
                width: 32, // Match desired Icon size
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : _chatSprite != null
                ? SpriteWidget(
                    sprite: _chatSprite!,
                  )
                : const Icon(
                    // Fallback icon if sprite fails to load
                    Icons
                        .chat_bubble_outline, // Or Icons.error or Icons.pending
                    size: 32,
                    color: Colors.black,
                  ),
      ),
    );
  }
}
