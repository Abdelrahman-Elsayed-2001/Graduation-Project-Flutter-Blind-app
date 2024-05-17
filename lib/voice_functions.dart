import 'package:flutter_tts/flutter_tts.dart';

import 'current_page.dart';

FlutterTts flutterTts = FlutterTts();

Future<void> voice(String text) async {
  final arabicPattern = RegExp(r'[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]');
  final englishPattern = RegExp(r'[A-Za-z]');
  final digitPattern = RegExp(r'\d');

  if (arabicPattern.hasMatch(text)) {
    await flutterTts.setLanguage('ar');
  } else if (englishPattern.hasMatch(text)) {
    await flutterTts.setLanguage('en-US');
  } else if (digitPattern.hasMatch(text)) {
    await flutterTts.setLanguage('en-US');
  } else {
    print('Failed to detect language.');
    return;
  }

  // Adjust other TTS settings if needed
  await flutterTts.setPitch(1);

  await flutterTts.speak(text);
}


void stopListening() {
    flutterTts.stop();
    AppState.isListening=false;
  }
