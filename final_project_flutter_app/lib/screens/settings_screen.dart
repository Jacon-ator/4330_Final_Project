import 'package:final_project_flutter_app/src/audio/audio_manager.dart';
import 'package:flutter/material.dart';


class SettingsPage extends StatefulWidget {
  final VoidCallback onClose;

  const SettingsPage({super.key, required this.onClose});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool musicEnabled = true;
  bool soundEffectsEnabled = true;
  double musicVolume = 1.0; // Range: 0.0 to 1.0
  double soundEffectsVolume = 1.0;

  @override
  void initState() {
    super.initState();
    musicVolume = AudioManager().musicVolume;
    soundEffectsVolume = AudioManager().sfxVolume;
  }

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

                // MUSIC SECTION
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
                      // Optional: Mute music volume when disabled
                      AudioManager().setMusicVolume(musicEnabled ? musicVolume : 0.0);
                    });
                  },
                ),
                Slider(
                  value: musicVolume,
                  onChanged: musicEnabled
                      ? (value) {
                          setState(() {
                            musicVolume = value;
                            AudioManager().setMusicVolume(value);
                          });
                        }
                      : null,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: "${(musicVolume * 100).round()}%",
                  activeColor: Colors.greenAccent,
                  inactiveColor: const Color.fromARGB(255, 162, 123, 123),
                ),

                // SFX SECTION
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
                      // Optional: Mute SFX volume when disabled
                      AudioManager().setSfxVolume(soundEffectsEnabled ? soundEffectsVolume : 0.0);
                    });
                  },
                ),
                Slider(
                  value: soundEffectsVolume,
                  onChanged: soundEffectsEnabled
                      ? (value) {
                          setState(() {
                            soundEffectsVolume = value;
                            AudioManager().setSfxVolume(value);
                          });
                        }
                      : null,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: "${(soundEffectsVolume * 100).round()}%",
                  activeColor: Colors.greenAccent,
                  inactiveColor: Colors.grey,
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: widget.onClose,
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
