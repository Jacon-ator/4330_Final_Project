import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/components/volume_control.dart';
import 'package:final_project_flutter_app/services/auth_service.dart';
import 'package:final_project_flutter_app/services/database_service.dart';
import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {
  final String name;

  const ChatListPage({super.key, required this.name});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  String recipientemail = "";
  List<QueryDocumentSnapshot> chatList = [];

  // Track if there's an error message to display
  String? errorMessage;

  // Load only once when screen opens
  @override
  void initState() {        
    super.initState();
    loadUserChats();
  }

  //loads the user's chats
  void loadUserChats() async {
    chatList = await _databaseService.getAllChats();

    print("Called loadUserChats");

    //update the list of chats
    setState(() {
      chatList = chatList;
    });
  } 

  void _createNewChat(){
    _databaseService.createNewChat(recipientemail);
    //updates the visible list of chats
    loadUserChats();
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
                      'List of Chats',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF468232),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                            recipientemail = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        onPressed: _createNewChat,
                        child: const Text(
                          'Create Chat',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
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
