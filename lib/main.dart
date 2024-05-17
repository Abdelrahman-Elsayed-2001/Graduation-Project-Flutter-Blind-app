import 'package:chatgpt_course/HomeScreen.dart';
import 'package:chatgpt_course/providers/models_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'Voice_Functions.dart';
import 'chat/login_screen.dart';
import 'constants/constants.dart';
import 'current_page.dart';
import 'providers/chats_provider.dart';

void onErrorCallback(dynamic error) {
  switch (AppState.currentPage) {
    case 'ChatScreen':
      voice('Unable to hear your voice, Chat Screen');
        AppState.isListening=false;
        stopListening();
      break;
    case 'ContactScreen':
      voice('Unable to hear your voice, Contact Screen');
        AppState.isListening=false;
        stopListening();
      break;
    case 'HomeScreen':
      voice('Unable to hear your voice, Home Screen');
        AppState.isListening=false;
        stopListening();
      break;
    default:
      voice('Unable to hear your voice, please try again');
        AppState.isListening=false;
        stopListening();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  stt.SpeechToText _speech = stt.SpeechToText();
  bool available = await _speech.initialize(
    onStatus: (status) => print('status: $status'),
    onError: onErrorCallback,
  );


  // Initialize Flutter TTS
  FlutterTts flutterTts = FlutterTts();
  await flutterTts.setLanguage("en-US");
  await flutterTts.setSpeechRate(0.4);

  // Play voice message only for the first time
  if (isFirstTime) {
    await flutterTts.speak("This message is only displayed the first time you open the application, to help you be familiar with the it."
        "The screen contains a navigation bar at the top with a title,"
        "\"Main Menu\", and two icons: a settings icon on the top left corner and a help icon on the top right corner. "
        "The settings icon can be used to access the app's settings, "
        "while the help icon provides a guide for blind users. Below the navigation bar, "
        "there is a scrollable list of boxes or buttons which you can press to use the functionalities this application offers. "
        "The first box is labeled \"Chat with Chat-GPT\","
        " and when the user taps on it, they are taken to a screen where they can chat with an AI"
        ". The second box is labeled \"Chat with Friends\", "
        "and when the user taps on it, "
        "they are taken to a screen where they can chat with their friends."
        "The third box is labeled \"Detect Objects Using Camera\","
        "and when the user taps on it, they are taken to a screen where they can use their"
        " phone's camera to detect objects."
        "You can also long press on any box and it will read to you which functionality this box offers, you can hear this message again in user's guide button on the upper right corner");


    await prefs.setBool('isFirstTime', false);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ModelsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter ChatBOT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: scaffoldBackgroundColor,
            appBarTheme: AppBarTheme(
              color: cardColor,
            )),
        home: LoginScreen(),
      ),
    );
  }
}