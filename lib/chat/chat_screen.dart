import 'package:chatgpt_course/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Voice_Functions.dart';
import '../current_page.dart';
import '../string_similarity_functions.dart';
import '../widgets/UserImg.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhotoUrl;

  ChatScreen({
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhotoUrl,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  final page= "ChatScreen";
  String _text = '';
  String voiceMessage='';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late String conversationId='wait';

  @override
  initState() {
    super.initState();
    _getConversationId();

    // Updating the currentPage
    AppState.currentPage = 'ChatScreen';
  }


  startListening() async {
    _messageController.text='';
    await Future.delayed(const Duration(milliseconds: 1500));
    bool available = await _speech.initialize(
      onStatus: (status) => print('status: $status'),
      onError: (error) => {
        voice('unable to hear your voice'),
        stopListening()
      },
    );

    if (available) {
      _speech.listen(
        onResult: (result) async {
          setState(() {
            voiceMessage = result.recognizedWords.toLowerCase();
            _messageController.text=voiceMessage;
          });

          if (result.finalResult) {
            await voice("are you want send the message");
            messageConfirmation();
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

  messageConfirmation() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    bool available = await _speech.initialize(
      onStatus: (status) => print('status: $status'),
      onError: (error) => {
        voice('unable to hear your voice'),
        stopListening()
      },
    );

    if (available) {
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords.toLowerCase();
          });

          if (result.finalResult) {
            _onRecognitionComplete();
          }
        },
        listenFor: const Duration(seconds: 20),
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

    if (messageAgree(_text)) {
      _sendMessage();
      voice('message send successfully.');
    } else if (cancel(_text)) {
      _messageController.text='';
      voice('message Canceled.');
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


  Future<void> _getConversationId() async {
    bool exist=false;
    QuerySnapshot querySnapshot1 =await _firestore.collection("message").where("from_uid", whereIn: [widget.currentUserId, widget.otherUserId]).get();
    for (int i = 0; i < querySnapshot1.size; i++) {
      if (querySnapshot1.docs[i].get('from_uid') as String == widget.currentUserId){
        if (querySnapshot1.docs[i].get('to_uid') as String == widget.otherUserId ){
          setState(() {
            conversationId=querySnapshot1.docs[i].id;
          });
          exist=true;
          print(1);
          print(conversationId);
          break;
        }
      }
      else{
          if (querySnapshot1.docs[i].get('to_uid') as String == widget.currentUserId ){
            setState(() {
              conversationId=querySnapshot1.docs[i].id;
            });
            exist=true;
            print(2);
            print(conversationId);
            break;
          }
        }
      }

    if(!exist){
      final DocumentReference documentRef = await _firestore.collection("message").add({
        'from_uid': widget.currentUserId,
        'to_uid': widget.otherUserId,
      });
      setState(() {
        conversationId=documentRef.id;
      });

      print(3);
      print(conversationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            UserImg(image: widget.otherUserPhotoUrl),
            const SizedBox(width: 8),
            Text(
              widget.otherUserName,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("message")
                  .doc(conversationId)
                  .collection("msglist")
                  .orderBy('addtime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                // Extract the list of messages from the snapshot
                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageText = message['content'] ?? '';
                    final uid = message['uid'] as String;
                    final isMyMessage = uid == widget.currentUserId;
                    final maxWidthPercentage = 0.4;

                    return Row(
                      mainAxisAlignment:
                      isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * maxWidthPercentage,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isMyMessage ? Colors.blue : Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              messageText,
                              style: TextStyle(fontSize: 18, color: Colors.white),
                              textAlign: isMyMessage ? TextAlign.right : TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );

              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      _sendMessage();
                      // await voice('what is your message');
                      // startListening();
                    },
                    icon: const Icon(Icons.mic, color: Colors.white),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    _messageController.clear();
    if (messageText.isNotEmpty) {

      final DocumentReference documentRef = await _firestore.collection("message").doc(conversationId).collection("msglist")
          .add({
        'uid':widget.currentUserId,
        'content': messageText,
        'type': 'text',
        'emotion': 'inProgress',
        'addtime': Timestamp.now()
      ,
      });
        _firestore
            .collection("message")
            .doc(conversationId)
            .collection("emotionInProgress")
            .add({"messageID": documentRef.id});


    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
