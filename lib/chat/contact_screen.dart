import 'package:chatgpt_course/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../current_page.dart';
import '../string_similarity_functions.dart';
import '../voice_functions.dart';
import '../widgets/ContactBox.dart';
import '../widgets/UserImg.dart';
import 'chat_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ContactScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const ContactScreen({super.key,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  ContactScreenState createState() => ContactScreenState();
}

class ContactScreenState extends State<ContactScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  String _text = '';
  String voiceMessage='';
  final TextEditingController _textEditingController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentUserId = '';
  String currentUserName = '';
  String userPhotoString = '';
  bool showContacts = true;
  bool showProfile = false;
  bool showForm = false;
  int selectedButtonIndex = 0;
  bool isReadingProfileInfo = false;
  @override
  void initState() {
    super.initState();

// Updating the currentPage
    AppState.currentPage = 'ContactScreen';

    currentUserId = widget.currentUserId;
    currentUserName = widget.currentUserName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Screen'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48), // Adjust the height as needed
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onLongPress: () {
                  voice("This is the contacts section button, short press to enter");
                },
                child: IconButton(
                  icon: const Icon(Icons.people),
                  onPressed: () {
                    if (isReadingProfileInfo) {
                      stopListening();
                    }
                    setState(() {
                      showContacts = true;
                      showProfile = false;
                      selectedButtonIndex = 0;
                    });
                    stopListening();
                    voice("You are now in the contacts section");
                  },
                  iconSize: 32,
                  padding: EdgeInsets.zero,
                  color: selectedButtonIndex == 0 ? Colors.blue : null,
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  voice("This is the profile section button, short press to enter");
                },
                child: IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    setState(() {
                      showContacts = false;
                      showProfile = true;
                      selectedButtonIndex = 1;
                    });
                    if (!isReadingProfileInfo) {
                      _readProfileInformation();
                    }
                  },
                  iconSize: 32,
                  padding: EdgeInsets.zero,
                  color: selectedButtonIndex == 1 ? Colors.blue : null,
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  voice("This is the Add User section button, short press to enter");
                  },
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    if (isReadingProfileInfo) {
                      stopListening();
                    }
                    setState(() {
                      showContacts = true;
                      showProfile = false;
                      selectedButtonIndex = 0;
                    });
                    stopListening();
                    // await voice("You are now in the add user section,what is the user ID you want to add?");
                    // startListening();
                    myForm();
                },
                ),
              ),
            ],
          ),
        ),
      ),
      body: showContacts
          ? StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users').doc(AppState.currentUserDocID).collection('friends')
            .where("id", isNotEqualTo: currentUserId) // Exclude the current user from the list
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final users = snapshot.data?.docs ?? [];


          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user['id'];
              // _firestore.collection('users').where("id", isEqualTo: userId).get();
              // print("\n\n\n");
              // print(userId);
              final userName = user['name'];
              final userPhotoUrl = user['photourl'];

              return ContactWidget(
                name: userName,
                onTap: () {
                  _navigateToChatScreen(
                    userId,
                    userName,
                    userPhotoUrl,
                  );
                },
                image: userPhotoUrl,
              );
            },
          );
        },
      )
          : Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  UserImg(
                    image: userPhotoString,
                    size: 50,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    currentUserName,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'ID:',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    currentUserId,
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
            if (AppState.isListening) {
              stopListening();
            } else {
              voice("how can i help you in Contact Screen?");
              myForm();
            }
          }
        ,
        backgroundColor: AppState.isListening ? Colors.red : Colors.blue, // Change button color based on whether the app is listening or not
        child: Icon(AppState.isListening ? Icons.mic : Icons.mic_none),
      ),
    );

  }

  void myForm(){
    // startListening();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Form'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  labelText: 'Enter text',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String text = _textEditingController.text;
                String result = await addNewUser(text);
                setState(() {
                  _textEditingController.text = result;
                });
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
  void _navigateToChatScreen(
      String otherUserId,
      String otherUserName,
      String otherUserPhotoUrl,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUserId: currentUserId,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          otherUserPhotoUrl: otherUserPhotoUrl,
        ),
      ),
    );
  }

  Future<String> addNewUser(String newUserID) async {
    if (newUserID==currentUserId){
      return "can't add your self";
    }

    try {
      final userQuerySnapshot = await _firestore
          .collection('users')
          .where("id", isEqualTo: newUserID)
          .get();

      if (userQuerySnapshot.docs.isEmpty) {
        return "User does not exist";
      }
      
      final currentUserDocRef = _firestore.collection('users').doc(AppState.currentUserDocID);

      final exist = await currentUserDocRef
          .collection('friends')
          .where("id", isEqualTo: newUserID)
          .get();
      if (exist.docs.isNotEmpty) {
        return "User Already exists";
      }

      await currentUserDocRef.collection('friends').doc().set(
          {
            "id":userQuerySnapshot.docs.first.get('id'),
            "name":userQuerySnapshot.docs.first.get('name'),
            "photourl":userQuerySnapshot.docs.first.get('photourl')
          });

      return "User added successfully";
    } catch (error) {
      return error.toString();
    }
  }


  Future<void> _readProfileInformation() async {
    setState(() {
      isReadingProfileInfo = true;
    });

    try {

      await voice('You Pressed on Profile Section:');
      await Future.delayed(const Duration(milliseconds: 2000));
      if(isReadingProfileInfo && !showContacts){
        await voice('Account Name: $currentUserName');
        await Future.delayed(const Duration(milliseconds: 3000));
      }
      if(isReadingProfileInfo && !showContacts){
        await voice('Your ID is');
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      if(isReadingProfileInfo && !showContacts) {
        for (var digit in currentUserId.split('')) {
          if (isReadingProfileInfo && showContacts) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: 620));
          await voice(digit);
        }
      }
    } finally {
      setState(() {
        isReadingProfileInfo = false;
      });
    }
  }


  startListening() async {
    _speech = stt.SpeechToText();
    _text='';

    bool available = await _speech.initialize(
      onStatus: (status) => print('status: $status'),
      onError: (error) => {
        stopListening(),
      },
    );

    if (available) {
      _speech.listen(
        onResult: (result) async {
          setState(() {
            voiceMessage = result.recognizedWords.toLowerCase();
            _text=voiceMessage;
            _textEditingController.text=_text;
          });

          if (result.finalResult) {
            await voice("are you want send the message");
            _onRecognitionComplete();
          }
        },

        onSoundLevelChange: null,
        cancelOnError: true,
        partialResults: true,
      );
      setState(() {
        AppState.isListening = true;
        _text = '';
      });
    } else {
      voice("Speech recognition is not available.");
    }


  }

  Future<void> _onRecognitionComplete () async {
    setState(() {
      AppState.isListening = false;
    });

    if (addUser(_text)) {
      voice('what is Contact I D?');
      // myForm();
    } else if (getContact(_text)) {
      voice('what is Contact name?');
      // myForm();
    }else if (cancel(_text)) {
      _textEditingController.text='';
      _text='';
      voice('Canceled.');
      stopListening();

    } else {
      print("$_text");
      voice('Sorry, I did not understand.');
      stopListening();
    }
  }

  void stopListening() {
    if (AppState.isListening) {
      _speech.stop();
      setState(() {
        AppState.isListening = false;
      });
    }
  }



}
