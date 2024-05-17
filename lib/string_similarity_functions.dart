import 'package:chatgpt_course/screens/HelpGuidePage.dart';
import 'package:chatgpt_course/screens/chat_screen_ai.dart';
import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
import 'Voice_Functions.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';





bool isTimerCommand(String text) {
final List<String> setStopwatchPhrases = [
"set timer for", "start timer for", "begin timer for"];
const double similarityThreshold = 0.6;
return setStopwatchPhrases.any((phrase) => StringSimilarity.compareTwoStrings(text.toLowerCase(), phrase) >= similarityThreshold);
}

void setTimer(RegExpMatch stopwatchMatch) {
final int duration = int.parse(stopwatchMatch.group(1)!);
final String unit = stopwatchMatch.group(2)!.toLowerCase();

int durationSeconds;

if (unit == 'second' || unit == 'seconds' || unit =='sec' || unit == 'secs') {
  durationSeconds = duration;
} else if (unit == 'min' || unit == 'mins' || unit == 'minute' || unit == 'minutes') {
  durationSeconds = duration * 60;
} else if (unit == 'hours' || unit == 'hour') {
  durationSeconds = duration * 60 * 60;
} else {
voice("Invalid duration unit. Please specify the duration in seconds or minutes.");
return;
}

FlutterAlarmClock.createTimer(durationSeconds);
voice("Timer started for $duration $unit");
}

bool isSetAlarmCommand(String text) {
  final List<String> setAlarmPhrases = [
    "make alarm for", "make alarm at", "wake me up at",
    "set alarm", "alarm", "set alarm at", "set alarm for"];
  const double similarityThreshold = 0.6;
  return setAlarmPhrases.any((phrase) => StringSimilarity.compareTwoStrings(text.toLowerCase(), phrase) >= similarityThreshold);
}

void setAlarm(RegExpMatch timeMatch) {
  final int hour = int.parse(timeMatch.group(1)!);
  final int minute = int.parse(timeMatch.group(2)!);
  final String period = timeMatch.group(3)!;
  final int hourOfDay = period == 'p.m.' ? hour + 12 : hour;

  final alarmTime = DateTime(DateTime
      .now()
      .year, DateTime
      .now()
      .month, DateTime
      .now()
      .day, hourOfDay, minute);
  voice("Alarm set at $hour:$minute $period");
  FlutterAlarmClock.createAlarm(alarmTime.hour, alarmTime.minute);
  // Use platform-specific API or library for scheduling the alarm
  // On Android, you can use the AlarmManager class or WorkManager library.
  // Refer to the Android documentation for details on how to schedule alarms.

  // Perform necessary actions when the alarm triggers (e.g., display a notification, play a sound)
}



  bool isTimeQuestion(String text) {
  final List<String> timeQuestions = [
    "What time is it?", "tell me the time", "what's the time", "what is the current time", "can you tell me the time",
    "do you know what time it is", "what time do you have", "could you give me the current time", "what's the current time",
    "please tell me the time", "what's the current time now", "what is the time at the moment", "what time is it right now",
    "can you give me the time", "what's the time at the moment", "do you know the time now", "what's the current time please",
    "what time is it now", "i need to know the time", "can you give me the current time", "what's the time on your clock",
    "what time is it on your watch", "what is the time on your device", "can you give me the time on your device"
  ];
  return timeQuestions.any((question) => StringSimilarity.compareTwoStrings(text.toLowerCase(), question) >= 0.7);
}

void getCurrentTime() {
  final DateTime now = DateTime.now();
  final int hour = now.hour > 12 ? now.hour - 12 : now.hour;
  final int minute = now.minute;
  final String period = now.hour > 12 ? 'pm' : 'am';
  voice('It is $hour:$minute $period');
}




bool isDateQuestion(String text) {
  final List<String> dateQuestions = [
    "What is today's date?", "tell me the date", "what's the date", "what is the current date", "can you tell me the date",
    "do you know what date it is", "what's the current date", "please tell me the date", "what's the date today",
    "what is the date today", "can you give me the date", "what's today's date", "what date is it today",
    "what is today's date please"
  ];
  return dateQuestions.any((question) => StringSimilarity.compareTwoStrings(text.toLowerCase(), question) >= 0.7);
}

void getCurrentDate() {
  final DateTime now = DateTime.now();
  final int day = now.day;
  final int month = now.month;
  final int year = now.year;
  voice('Today is $month/$day/$year');
}




bool isChatGPTQuestion(String text) {
  final List<String> chatGPTQuestions = ["ai", "open ai", "chat gpt", "chat gbt", "gbt", "chat gbt", "gpt", "open chat gpt",
    "ask ai", "ask gpt", "ask chat gpt", "bot", "smart ai", "speak to ai", "speak to chat", "speak to gpt", "chatbot",
    "open chat gbt", "chat with chat ai", "chat with ai", "chat with gbt", "chat with gpt", "talk with ai",
    "talk with chat gbt", "talk with chat gpt", "talk with gbt", "talk to a language model", "have a conversation with an AI",
    "interact with an intelligent chatbot", "engage with a natural language processing system", "communicate with a virtual assistant",
    "ask an intelligent agent", "consult an automated conversational agent", "discuss with a smart chat partner", "chat with an intelligent language generator",
    "converse with an AI language model", "talk to a machine learning chatbot", "have a dialogue with an advanced language AI",
    "converse with chatbot", "have a conversation with machine learning", "engage with intelligent chat", "chat with artificial intelligence",
    "talk to smart chatbot", "converse with automated chat", "exchange messages with bot", "speak with digital assistant"];
  return chatGPTQuestions.any((question) => StringSimilarity.compareTwoStrings(text.toLowerCase(), question) >= 0.7);
}

void openChatGPTScreen(BuildContext context) {
  voice("You've entered chat bot section");
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const chatscreenAI(),
    ),
  );
}



void openGuide(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const GuidePage(),
    ),
  );
}

bool isGuideQuestion(String text) {
  final List<String> guideQuestions = ["open guide", "guide", "get guide", "do you have a guide?", "the guide"];
  return guideQuestions.any((question) => StringSimilarity.compareTwoStrings(text.toLowerCase(), question) >= 0.7);
}



bool isEmergencyButton(String text) {
  final List<String> emergencyQuestions = ["Emergency","Open Emergency", "Press on emergency Button","button emergency", 'help emergency', 'help me'];
  return emergencyQuestions.any((question) => StringSimilarity.compareTwoStrings(text.toLowerCase(), question) >= 0.7);
}

bool messageAgree(String text) {
  final List<String> messageAgree = ["agree","yes", "send","send the message", 'of course', 'sure'];
  return messageAgree.any((question) => StringSimilarity.compareTwoStrings(text.toLowerCase(), question) >= 0.7);
}
//
bool addUser(String text) {
  final List<String> messageAgree = ["add","add user", "add friend","new user"];
  return messageAgree.any((question) => StringSimilarity.compareTwoStrings(text.toLowerCase(), question) >= 0.7);
}

bool getContact(String text) {
  final List<String> messageAgree = ["open user","open chat", "with user","chat with","open contact","chat with friend"];
  return messageAgree.any((question) => StringSimilarity.compareTwoStrings(text.toLowerCase(), question) >= 0.7);
}

bool cancel(String text) {
  final List<String> messageAgree = ["cancel","no", "stop","delete", 'nope', 'back',"do not","don't","exit"];
  return messageAgree.any((question) => StringSimilarity.compareTwoStrings(text.toLowerCase(), question) >= 0.7);
}
//

void openEmergency(BuildContext context) {
  voice('Emergency Button was Activated!');
  //Navigator.push(
   // context,
    //MaterialPageRoute(
     // builder: (context) => const EmergencyButtonScreen(),
    //),
  //);
}