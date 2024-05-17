import 'package:chatgpt_course/screens/HelpGuidePage.dart';
import 'package:chatgpt_course/string_similarity_functions.dart';
import 'package:chatgpt_course/widgets/home_screen_box.dart';
import 'package:flutter/material.dart';
import 'package:chatgpt_course/screens/chat_screen_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';
import 'dart:async';

import 'Voice_Functions.dart';
import 'chat/contact_screen.dart';
import 'chat/login_screen.dart';
import 'current_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.currentUserId, required this.currentUserName,required this.currentUserDocID}) : super(key: key);
  final String currentUserId;
  final String currentUserName;
  final String currentUserDocID;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final page= "HomeScreen";

  @override
  void initState() {
    super.initState();

// Updating the currentPage
    setState(() {
      AppState.currentPage = 'HomeScreen';
      AppState.currentUserDocID = widget.currentUserDocID;
    });

  }

  stt.SpeechToText _speech = stt.SpeechToText();
  String _text = '';


  void onErrorCallback(String page) {
    switch (page) {
      case 'ChatScreen':
        voice('Unable to hear your voice, Chat Screen');
        break;
      case 'ContactScreen':
        voice('Unable to hear your voice, Contact Screen');
        break;
      case 'HomeScreen':
        voice('Unable to hear your voice, Home Screen');
        break;
      default:
        voice('Unable to hear your voice, please try again');
        stopListening();
    }
  }

   startListening() async {
     await voice('Hi,How can I help you?');
     await Future.delayed(const Duration(milliseconds: 2000));
    bool available = await _speech.initialize(
      onStatus: (status) => print('status: $status'),
      onError: (error) => {

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
        listenFor: const Duration(seconds: 10),
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

    //Alarm
    final RegExp timeRegex = RegExp(r'(\d{1,2}):(\d{2}) ?([ap].m.)');
    final RegExpMatch? timeMatch = timeRegex.firstMatch(_text.toLowerCase());

    final RegExp stopwatchRegex = RegExp(r'(\d+) (seconds?|minutes|hours?)');
    final RegExpMatch? stopwatchMatch = stopwatchRegex.firstMatch(_text.toLowerCase());

    if (isTimerCommand(_text) && stopwatchMatch != null) {
      setTimer(stopwatchMatch);
    } else if (isTimerCommand(_text) && stopwatchMatch == null) {
      print(_text);
      voice("You didn't specify the duration correctly. For example, you need to say 'Set timer for 5 minutes.'");
    }



    else if (isSetAlarmCommand(_text) && timeMatch != null) {
      setAlarm(timeMatch);
    } else if (isSetAlarmCommand(_text) && timeMatch == null) {
      voice("You didn't specify time or period correctly. for example you need to say Set alarm at 12:45 pm.");


    } else if (isGuideQuestion(_text)) {
      openGuide(context);

    } else if (isChatGPTQuestion(_text)) {
      openChatGPTScreen(context);

    } else if (isTimeQuestion(_text)) {
      getCurrentTime();

    } else if (isEmergencyButton(_text)) {
      openEmergency(context);

    } else if (StringSimilarity.compareTwoStrings(_text.toLowerCase(), "stop") >= 0.7) {
      voice('Stopped');
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        centerTitle: true,
        backgroundColor: const Color(0xFF3A3A3A),
        actions: [
          GestureDetector(
            onLongPress: () {
              voice('This is guide button, short press it to enter guide section');
            },
            child: IconButton(
              icon: const Icon(
                Icons.help,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GuidePage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      body: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            BoxWidget(
              icon: Icons.chat,
              label: 'Chat with Chat-BOT',
              color: const Color(0xFF3A3A3A),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const chatscreenAI(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            BoxWidget(
              icon: Icons.person,
              label: 'Chat with Friends',
              color: Colors.blueGrey,
              onTap: () {
                Navigator.push(
                  context,
                  // MaterialPageRoute(builder: (context) => LoginScreen()),
                  MaterialPageRoute(builder: (context) => ContactScreen(
                    currentUserId: widget.currentUserId,
                    currentUserName: widget.currentUserName,
                    ),
                  ));
              },
            ),
            const SizedBox(height: 20),
            BoxWidget(
              icon: Icons.camera_alt,
              label: 'Detect Objects Using Camera',
              color: Colors.orangeAccent,
              onTap: () {
                // Navigate to your camera detection screen here
              },
            ),
            const SizedBox(height: 20),
              BoxWidget(
                icon: Icons.warning,
                label: 'Emergency Button',
                color: Colors.red,
                onTap: () {
                  openEmergency(context);
                  // ADD EMERGENCY BUTTON CODE HERE.. You will find an empty function in string_similarity_functions file  called openEmergency()
                },
              ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final status = await Permission.microphone.request();
          if (status == PermissionStatus.granted) {
            if (AppState.isListening) {
              stopListening();
            } else {
              startListening();

            }
          } else {
            voice("Access denied");
          }
        },
        backgroundColor: AppState.isListening ? Colors.red : Colors.blue, // Change button color based on whether the app is listening or not
        child: Icon(AppState.isListening ? Icons.mic : Icons.mic_none),
      ),

    );

  }
}
