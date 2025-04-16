import 'package:flutter/material.dart';

//not going to lie guys as a basic just getting started thing this is staright chatgpt
//but i will change it up and make it better for our specific app once i get the chance
//the only settings options to change in this so far is music on/off and sound effects on/off

class SettingsPage extends StatefulWidget {
  final VoidCallback onClose;

  const SettingsPage({Key? key, required this.onClose}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool musicEnabled = true;
  bool soundEffectsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Music'),
                value: musicEnabled,
                onChanged: (value) {
                  setState(() {
                    musicEnabled = value;
                    // Add logic to toggle music in game
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Sound Effects'),
                value: soundEffectsEnabled,
                onChanged: (value) {
                  setState(() {
                    soundEffectsEnabled = value;
                    // Add logic to toggle sound effects in game
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onClose,
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}