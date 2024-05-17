import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../Voice_Functions.dart';

class Word {
  String word;
  int start;
  int end;

  Word({required this.word, required this.start, required this.end});
}

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  late FlutterTts _flutterTts;
  final String _text = "You are now at User's Guide Section, to go back to Main Menu press on back button at the upper left corner.\n \n"
      "In the Main Menu, there are two buttons: a settings button on the top left corner and a help button on the top right corner.\n \n"
      "The settings icon can be used to access the app's settings, "
      "while the help icon provides a guide for blind users.\n \nBelow the navigation bar, "
      "there is a scrollable list of boxes or buttons which you can press to use the functionalities this application offers.\n \n"
      "The first box is labeled Chat with Chat-BOT,"
      " when the user taps on it, they are taken to a screen where they can chat with an AI"
      ".\n \nThe second box is labeled Chat with Friends, "
      "when the user taps on it, they are taken to a screen where they can chat with their friends.\n \n"
      "The third box is labeled Detect Objects Using Camera,"
      " when the user taps on it, they are taken to a screen where they can use their"
      " phone's camera to detect objects.\n \n"
      "You can also use voice commands to use any functionality by pressing on the button at the bottom left corner of the screen to make the app listen to you,"
      " for example you can tap that button and say, open AI, and chat gbt screen would pop up on your screen.\n \n"
      "You need to give permission to the application to access your microphone only the first time you tap on the voice button.\n \n"
      "You can also long press on any box and it will read to you which functionality this box offers.\n \nTo repeat press on replay button at the top right corner.";

  int _currentWordIndex = -1;
  final List<Word> _words = [];

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _parseText();
    _speakAndHighlightText();
  }

  Future<void> _speakAndHighlightText() async {
    _flutterTts.setProgressHandler((String? text, int start, int end, String word) {
      for (int i = 0; i < _words.length; i++) {
        if (start >= _words[i].start && end <= _words[i].end) {
          setState(() {
            _currentWordIndex = i;
          });
          break;
        }
      }
    });
    await _flutterTts.speak(_text);
  }

  void _parseText() {
    List<String> textWords = _text.split(' ');
    int start = 0;
    for (String word in textWords) {
      int end = start + word.length;
      _words.add(Word(word: word, start: start, end: end));
      start = end + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide'),
        leading: GestureDetector(
          onLongPress: (){
            voice("Back to main menu button");
          },
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _flutterTts.stop();
              Navigator.pop(context);
            },
          ),
        ),
        actions: <Widget>[
          GestureDetector(
            onLongPress: (){
              voice("Replay Guide");
            },
            child: IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                _speakAndHighlightText();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Scrollbar(
            child: ListView(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: _words.map((word) {
                      final isCurrentWord = _words.indexOf(word) == _currentWordIndex;
                      final style = TextStyle(
                        fontSize: 24.0,
                        fontWeight: isCurrentWord ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentWord ? Colors.red : Colors.white,
                      );
                      return TextSpan(text: '${word.word} ', style: style);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
