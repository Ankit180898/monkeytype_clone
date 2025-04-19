import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TypingTestController extends GetxController {
  final String fixedSentence = "The quick brown fox jumps over the lazy dog"; // Fixed sentence
  var currentText = ''.obs; // The text to type
  var typedText = ''.obs; // The user's input
  var correctChars = 0.obs;
  var incorrectChars = 0.obs;
  var isTestActive = false.obs;
  var isTestComplete = false.obs;
  var testDuration = 15.obs; // Default duration
  var timeLeft = 15.obs;
  var wpm = 0.0.obs;
  var accuracy = 100.0.obs;
  var cursorPosition = 0.obs;
  Timer? _timer;
  final textFieldController = TextEditingController();
  final RxList<double> wpmHistory = <double>[].obs;
// Store timestamps for each measurement
final RxList<double> timePoints = <double>[].obs;
// Timer for collecting data points
Timer? _dataCollectionTimer;
  DateTime testStartTime = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    generateNewTest();
  }

  @override
  void onClose() {
    _timer?.cancel();
    textFieldController.dispose();
    super.onClose();
  }

  void generateNewTest() {
    currentText.value = fixedSentence; // Use the fixed sentence
    typedText.value = '';
    isTestComplete.value = false;
    isTestActive.value = false;
    correctChars.value = 0;
    incorrectChars.value = 0;
    timeLeft.value = testDuration.value;
    wpm.value = 0.0;
    accuracy.value = 100.0;
    cursorPosition.value = 0;
    textFieldController.clear();
  }

  void startTest() {
  
    if (!isTestActive.value && !isTestComplete.value) {
      isTestActive.value = true;
      _startTimer();
      testStartTime = DateTime.now();
  startDataCollection();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
        _calculateStats();
      } else {
        endTest();
      }
    });
  }

  void checkTypedText(String value) {
    if (!isTestActive.value && value.isNotEmpty) {
      startTest();
    }

    if (isTestActive.value && !isTestComplete.value) {
      typedText.value = value;
      cursorPosition.value = value.length;
      _checkAccuracy();
    }
  }

  void _checkAccuracy() {
    String targetText = currentText.value;
    int checkLength = typedText.value.length;

    correctChars.value = 0;
    incorrectChars.value = 0;

    for (int i = 0; i < checkLength; i++) {
      if (i < targetText.length) {
        if (typedText.value[i] == targetText[i]) {
          correctChars.value++;
        } else {
          incorrectChars.value++;
        }
      }
    }

    if (typedText.value.length >= targetText.length) {
      endTest();
    }
  }

  void _calculateStats() {
    double minutes = (testDuration.value - timeLeft.value) / 60.0;
    if (minutes > 0) {
      wpm.value = (correctChars.value / 5) / minutes;
    }

    int totalChars = correctChars.value + incorrectChars.value;
    if (totalChars > 0) {
      accuracy.value = (correctChars.value / totalChars) * 100;
    }
  }

  void endTest() {
    isTestActive.value = false;
    isTestComplete.value = true;
     _dataCollectionTimer?.cancel();
  _dataCollectionTimer = null;
    _timer?.cancel();

    _calculateStats();
  }

  void restartTest() {
    _timer?.cancel();
    generateNewTest();
  }

  void setTestDuration(int seconds) {
    testDuration.value = seconds;
    timeLeft.value = seconds;
    restartTest();
  }

  void startDataCollection() {
  // Clear previous data
  wpmHistory.clear();
  timePoints.clear();
  
  // Collect data every 500ms
  _dataCollectionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
    // Calculate current WPM
    final elapsedTimeMinutes = timer.tick * 0.5 / 60; // Convert to minutes
    if (elapsedTimeMinutes > 0) {
      // Calculate characters typed correctly so far
      final currentCorrectChars = _countCorrectChars();
      // WPM formula: (characters / 5) / minutes
      final currentWpm = (currentCorrectChars / 5) / elapsedTimeMinutes;
      
      // Add data point
      wpmHistory.add(currentWpm);
      timePoints.add(elapsedTimeMinutes * 60); // Store time in seconds
    }
  });
}
int _countCorrectChars() {
  int correct = 0;
  String typed = typedText.value;
  String target = currentText.value;
  
  for (int i = 0; i < typed.length && i < target.length; i++) {
    if (typed[i] == target[i]) {
      correct++;
    }
  }
  
  return correct;
}

  void stopDataCollection() {
    _dataCollectionTimer?.cancel();
    _dataCollectionTimer = null;
  }
}