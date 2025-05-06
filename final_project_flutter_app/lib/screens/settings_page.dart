import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onClose;

  const SettingsPage({super.key, required this.onClose});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SFXManager _sfxManager = SFXManager();
  bool musicEnabled = true;
  bool soundEffectsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Card(
          color: Colors.grey[850],
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text(
                    'Music',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: musicEnabled,
                  activeColor: Colors.greenAccent,
                  onChanged: (value) {
                    setState(() {
                      musicEnabled = value;
                      // Add logic to toggle music in game
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text(
                    'Sound Effects',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: soundEffectsEnabled,
                  activeColor: Colors.greenAccent,
                  onChanged: (value) {
                    setState(() {
                      soundEffectsEnabled = value;
                      // Add logic to toggle sound effects in game
                    });
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    _sfxManager.playButtonSelect();
                    widget.onClose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
