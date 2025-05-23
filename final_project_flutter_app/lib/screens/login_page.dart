import 'package:final_project_flutter_app/audio/audio_manager.dart';
import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/components/volume_control.dart';
import 'package:final_project_flutter_app/screens/signup_page.dart';
import 'package:final_project_flutter_app/services/auth_service.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final String name;

  const LoginPage({super.key, required this.name});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //fields for the entered email and password and an AuthService
  String email = '';
  String password = '';
  AuthService authservice = AuthService();
  final AudioManager _audioManager = AudioManager();
  final SFXManager _sfxManager = SFXManager();

  // Track if there's an error message to display
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Initialize and play the main theme music
    _initAudio();
  }
  
  Future<void> _initAudio() async {
    print('[LOGIN PAGE] Starting audio initialization');
    try {
      // First stop any currently playing audio to ensure a clean start
      await FlameAudio.bgm.stop();
      
      // Initialize audio manager
      await _audioManager.initialize();
      
      // Play the main theme
      print('[LOGIN PAGE] Playing main theme');
      await _audioManager.playMainTheme();
      print('[LOGIN PAGE] Main theme started successfully');
    } catch (e) {
      print('[LOGIN PAGE] Error initializing audio: $e');
    }
  }

  void _login() async {
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both email and password';
      });
      return;
    }

    try {
      final result = await authservice.login(email: email, password: password);
      if (result != null) {
        // Navigates to the game screen after successful signup
        Navigator.of(context).pushReplacementNamed('/game');
      } else {
        setState(() {
          errorMessage = 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF468232),
      body: Stack(
        children: [
          // Background image with poker elements
          Image.asset(
            'assets/images/art/Title Screen.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Add a semi-transparent overlay to make the form more readable
          Container(
            color: const Color(0xFF468232).withOpacity(0.7),
            width: double.infinity,
            height: double.infinity,
          ),
          // No title text - removed as requested
          Center(
            child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              color: Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Log into an Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF468232),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          labelStyle: TextStyle(color: Colors.grey[700]),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF468232)),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey[700]),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF468232)),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _sfxManager.playButtonSelect();
                          _login();
                        },
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _sfxManager.playButtonSelect();
                        // Go directly to the game screen as a guest
                        Navigator.of(context).pushReplacementNamed('/game');
                      },
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: Color(0xFF468232),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Goes to the sign up page
                        Navigator.of(context).pushReplacement(MaterialPageRoute<LoginPage>(builder: (BuildContext context) {return SignUpPage(name: "bruh");}));
                      },
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          color: Color(0xFF468232),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
          ),
          // Volume control in top right corner
          Positioned(
            top: 20,
            right: 20,
            child: const VolumeControl(),
          ),
        ],
      ),
    );
  }
}
