import 'package:flutter/material.dart';
import 'package:final_project_flutter_app/audio/audio_manager.dart';

class VolumeControl extends StatefulWidget {
  const VolumeControl({super.key});

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  final AudioManager _audioManager = AudioManager();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Volume slider (always visible)
          Container(
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: StreamBuilder<bool>(
                  stream: _audioManager.muteStream,
                  initialData: _audioManager.isMuted,
                  builder: (context, muteSnapshot) {
                    final isMuted = muteSnapshot.data ?? false;

                    return StreamBuilder<double>(
                      stream: _audioManager.volumeStream,
                      initialData: _audioManager.volume,
                      builder: (context, volumeSnapshot) {
                        // When muted, show slider at 0, otherwise show actual volume
                        final displayValue =
                            isMuted ? 0.0 : (volumeSnapshot.data ?? 1.0);

                        return SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14),
                            activeTrackColor: const Color(
                                0xFF468232), // Green color matching the app theme
                            inactiveTrackColor: Colors.grey.withOpacity(0.3),
                            thumbColor: const Color(0xFF468232),
                          ),
                          child: Slider(
                            value: displayValue,
                            onChanged: (value) {
                              // If user adjusts slider while muted, unmute
                              if (isMuted) {
                                _audioManager.toggleMute();
                              }
                              _audioManager.setVolume(value);
                            },
                            min: 0.0,
                            max: 1.0,
                          ),
                        );
                      },
                    );
                  }),
            ),
          ),

          // Small gap between slider and button
          const SizedBox(width: 8),

          // Mute/unmute button
          StreamBuilder<bool>(
              stream: _audioManager.muteStream,
              initialData: _audioManager.isMuted,
              builder: (context, muteSnapshot) {
                final isMuted = muteSnapshot.data ?? false;

                return StreamBuilder<double>(
                    stream: _audioManager.volumeStream,
                    initialData: _audioManager.volume,
                    builder: (context, volumeSnapshot) {
                      final volume = volumeSnapshot.data ?? 1.0;

                      // Determine which icon to show based on mute state and volume level
                      IconData volumeIcon;
                      if (isMuted || volume == 0.0) {
                        volumeIcon = Icons.volume_off;
                      } else if (volume < 0.5) {
                        volumeIcon = Icons.volume_down;
                      } else {
                        volumeIcon = Icons.volume_up;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            volumeIcon,
                            color: const Color(
                                0xFF468232), // Green color matching the app theme
                          ),
                          onPressed: () {
                            // Toggle mute state only
                            _audioManager.toggleMute();
                          },
                        ),
                      );
                    });
              }),
        ],
      ),
    );
  }
}
