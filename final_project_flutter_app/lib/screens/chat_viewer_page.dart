import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/components/volume_control.dart';
import 'package:final_project_flutter_app/services/auth_service.dart';
import 'package:final_project_flutter_app/services/database_service.dart';
import 'package:flutter/material.dart';


class ChatViewerPage extends StatefulWidget {
  final DocumentReference docRef;

  const ChatViewerPage({super.key, required this.docRef});

  @override
  State<ChatViewerPage> createState() => _ChatViewerPageState();
}

class _ChatViewerPageState extends State<ChatViewerPage> {

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  String message = "";
  List<String> messagehistory = ["Loading messages..."];
  String? errorMessage;

  // Load only once when screen opens
  @override
  void initState() {        
    super.initState();
    loadMessages();
  }

  //loads the user's chats
  void loadMessages() async {
    List<String> newList = await _databaseService.readFromChat(widget.docRef);

    print("Called loadMessages");
    print(newList);
    //update the list of chats
    setState(() {
      messagehistory = List.from(newList);
    });
  }

  //sends a message to the other user
  void sendMessage() async {
    await _databaseService.writeToChat(widget.docRef, message);
    //clears the string holding the message
    setState(() {
      message = "";
    });
    //calls loadMessages to update the visible history
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFF468232),
      appBar: AppBar(
          title: Text("Chatting with ${widget.docRef.id}", selectionColor: Colors.white,),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          forceMaterialTransparency: true,
        ),
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
            constraints: const BoxConstraints(maxWidth: 850),
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
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        reverse: true,
                        itemCount: messagehistory.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            alignment: messagehistory[index].startsWith("Support:") 
                                ? Alignment.centerLeft 
                                : Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: messagehistory[index].startsWith("Support:") 
                                    ? Colors.green[200] 
                                    : Colors.blue[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Text(
                                messagehistory[index],
                                style: const TextStyle(fontSize: 18),
                              ),  
                            ),
                          );
                        }
                      ),
                    ),
                    
                    // Text input
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          message = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Send button
                    ElevatedButton(
                      onPressed: () {
                        if (message.trim().isNotEmpty) {
                          sendMessage();
                        }
                      },
                      child: const Text("Send"),
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

