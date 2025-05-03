import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class DatabaseService {

  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  Future getUserData() 
  async {
    //gets the reference to the user document to convert it to a userData
    final ref = _firestore.collection("users").doc(_auth.currentUser?.email).withConverter(
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

  Future createNewChat(String recipientemail)
  async {
    final recipientDoc = _firestore.collection("users").doc(recipientemail);
    String useremail = _auth.currentUser?.email ?? "Guest";
  
    //checks if the given email is a user in the database
    final docSnap = await recipientDoc.get();
    if (!docSnap.exists){
      print("Failed to find user with this email");
      return null;
    }

    //creates a document that will hold the chat in the user's "Chat" collection
    final chatRef = _firestore.collection('users').doc(_auth.currentUser?.email).collection("Chats").doc(_auth.currentUser?.email);
    chatRef.set({"1" : "${_auth.currentUser?.email} says hello!"});

    //adds the document reference to the recipient's "Chat" collection so that they share the document
    _firestore.collection("users").doc(recipientemail).collection("Chats").doc(useremail).set({"Document" : chatRef});

    //returns the reference to the newly created document so that you can go the chat viewer for the document
    return chatRef;
  }

  Future writeToChat(DocumentReference docRef, String message)
  async {
    //gets a snapshot of the document
    final docSnap = await docRef.get();

    //gets the length of the keys in the document to know what the index of the next message will be
    int doclength = (docSnap.data() as Map<String, dynamic>).keys.toList().length;

    //creates a header for the message with the user's email and appends the message to it
    String messageheader = "${_auth.currentUser?.email}: ";
    String fullmessage = messageheader + message;

    int nextlength = doclength++;
    String newIndex = nextlength.toString();
    docRef.update({newIndex : fullmessage});
  }

  Future readFromChat(DocumentReference docRef)
  async {
    //gets a snapshot of the document
    final docSnap = await docRef.get();
    //converts the data into a map of strings
    Map<String, String> chatmessages = docSnap.data() as Map<String, String>;
    
    //creates a new map with integers as the keys for sorting purposes
    Map<int, String> newMap = {};
    for (String key in chatmessages.keys){
      newMap[int.parse(key)] = chatmessages[key] ?? "Unable to show message";
    }

    //sorts the map by integer value so that newer messages are seen first
    Map<int, String> sortedMap = Map.fromEntries(newMap.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));

    //returns the sorted map
    return sortedMap;
  }

  Future getAllChats()
  async {

    //Gets the user's "Chat" collection
    CollectionReference collectRef = _firestore.collection("users").doc(_auth.currentUser?.email).collection("Chats");

    //adds all of the document references in the collection to a list
    List<QueryDocumentSnapshot> docList = [];
    collectRef.get().then(
      (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
          docList.add(docSnapshot);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    //returns the list
    return docList;
  }
}

//a class that represents the user's info
class userData {
  final String? email;
  final int? chips;         // Chips for playing in game
  final int? coins;         // Coins for shop
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
      ownCardSkin: data?['ownCardSkin'] ?? false
    );
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