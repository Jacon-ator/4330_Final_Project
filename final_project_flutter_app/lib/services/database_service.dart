import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/extensions.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<userData?> getUserData() async {
    //gets the reference to the user document to convert it to a userData
    final ref = _firestore
        .collection("users")
        .doc(_auth.currentUser?.email)
        .withConverter(
            fromFirestore: userData.fromFirestore,
            toFirestore: (userData userdata, _) => userdata.toFirestore());
    final docSnap = await ref.get();

    if (docSnap.exists) {
      return docSnap.data(); // returns userData
    } else {
      print("No user document found for: ${_auth.currentUser?.email}");
      return null; // avoids casting null to userData
    }
  }

  Future createNewChat(String recipientemail) async {
    final recipientDoc = _firestore.collection("users").doc(recipientemail);
    String useremail = _auth.currentUser?.email ?? "Guest";

    //checks if the given email is a user in the database
    final docSnap = await recipientDoc.get();
    if (!docSnap.exists) {
      print("Failed to find user with this email");
      return null;
    }

    // Make unique ID for each user
    String chatID;
    if (useremail.compareTo(recipientemail) < 0) {
      chatID = "${useremail}_$recipientemail";
    } else {
      chatID = "${recipientemail}_$useremail";
    }

    final chatDoc = _firestore.collection("chats").doc(chatID);

    // Creates the chat between the two users
    final chatSnap = await chatDoc.get();
    if (!chatSnap.exists) {
      await chatDoc
          .set({"0": "Chat started between $useremail and $recipientemail."});
    }

    // Links the chat for sender
    await _firestore
        .collection("users")
        .doc(useremail)
        .collection("Chats")
        .doc(recipientemail)
        .set({"chatID": chatID});

    // Links the chat for recipient
    await _firestore
        .collection("users")
        .doc(recipientemail)
        .collection("Chats")
        .doc(useremail)
        .set({"chatID": chatID});

    //returns the reference to the newly created document so that you can go the chat viewer for the document
    return chatDoc;
  }

  Future writeToChat(DocumentReference docRef, String message) async {
    //gets a snapshot of the document
    final docSnap = await docRef.get();

    //gets the length of the keys in the document to know what the index of the next message will be
    int doclength =
        (docSnap.data() as Map<String, dynamic>).keys.toList().length;

    //creates a header for the message with the user's email and appends the message to it
    String messageheader = "${_auth.currentUser?.email}: ";
    String fullmessage = messageheader + message;

    String newIndex = doclength.toString();
    docRef.update({newIndex: fullmessage});
  }

  Future readFromChat(DocumentReference docRef) async {
    //gets a snapshot of the document
    final docSnap = await docRef.get();

    //Check if document exists
    if (!docSnap.exists) {
      //Creates it with a welcome message
      await docRef.set(
          {"0": "Support chat started. Feel free to ask your questions here."});

      // Return that first message
      return [
        "Welcome to your private support chat. Feel free to ask your questions here."
      ];
    }

    //converts the data into a map of strings
    Map<String, dynamic> chatmessages = docSnap.data() as Map<String, dynamic>;

    //creates a new map with integers as the keys for sorting purposes
    Map<int, String> newMap = {};
    for (String key in chatmessages.keys) {
      if (int.tryParse(key) != null) {
        newMap[int.parse(key)] = chatmessages[key] ?? "Unable to load message";
      }
    }

    //sorts the map by integer value so that newer messages are seen first
    Map<int, String> sortedMap = Map.fromEntries(
        newMap.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));

    //creates a list to hold the messages
    List<String> messagehistory = [];
    for (int message in sortedMap.keys) {
      messagehistory.add(sortedMap[message] ?? "Unable to load message");
    }
    //returns the message history list
    messagehistory.reverse();
    return messagehistory;
  }

  Future<List<DocumentReference>> getAllChats() async {
    //Gets the user's "Chat" collection
    CollectionReference userChats = _firestore
        .collection("users")
        .doc(_auth.currentUser?.email)
        .collection("Chats");

    //adds all of the document references in the collection to a list
    List<DocumentReference> docList = [];

    // Get all chat documents from the user's Chats collection
    QuerySnapshot refSnap = await userChats.get();

    for (var doc in refSnap.docs) {
      String chatID = (doc.data() as Map<String, dynamic>)["chatID"] ?? "";
      if (chatID.isNotEmpty) {
        docList.add(_firestore.collection("chats").doc(chatID));
      }
    }

    //returns the list
    return docList;
  }
}

//a class that represents the user's info
class userData {
  final String? email;
  final int? chips; // Chips for playing in game
  final int? coins; // Coins for shop
  final int? games_won;
  final int? games_lost;
  final bool? ownTableSkin;
  final bool? ownCardSkin;

  userData({
    this.email,
    this.chips,
    this.coins,
    this.games_won,
    this.games_lost,
    this.ownTableSkin,
    this.ownCardSkin,
  });

  factory userData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return userData(
        email: data?['Email'],
        chips: data?['Chips'],
        coins: data?['Coins'],
        games_won: data?['Games Won'],
        games_lost: data?['Games Lost'],
        ownTableSkin: data?['ownTableSkin'] ?? false,
        ownCardSkin: data?['ownCardSkin'] ?? false);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "Email": email,
      if (chips != null) "Chips": chips,
      if (coins != null) "Coins": coins,
      if (games_won != null) "Games Won": games_won,
      if (games_lost != null) "Games Lost": games_lost,
      if (ownTableSkin != null) "ownTableSkin": ownTableSkin,
      if (ownCardSkin != null) "ownCardSkin": ownCardSkin
    };
  }
}
