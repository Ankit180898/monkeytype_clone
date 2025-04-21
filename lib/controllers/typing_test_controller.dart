import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/test_mode.dart';
import '../services/quote_service.dart';

class TypingTestController extends GetxController {
  final ScrollController scrollController = ScrollController(
    keepScrollOffset: true,
  );

  // Services
  final QuoteService quoteService = Get.put(QuoteService());

  // Test configuration
  var testMode = TestMode.words.obs;
  var selectedLength = 'short'.obs;
  var wordCount = 25.obs;
  var testDuration = 15.obs;

  // Test state
  var currentText = ''.obs;
  var typedText = ''.obs;
  var correctChars = 0.obs;
  var incorrectChars = 0.obs;
  var isTestActive = false.obs;
  var isTestComplete = false.obs;
  var timeLeft = 15.obs;
  var wpm = 0.0.obs;
  var accuracy = 100.0.obs;
  var cursorPosition = 0.obs;
  final double fontSize = 18.0; // Default font size similar to MonkeyType


  // Line tracking
  var currentLineIndex = 0.obs;
  final List<String> lines = [];
  double containerWidth = 0.0;

  // UI controller
  final textFieldController = TextEditingController();

  // Performance tracking
  Timer? _timer;
  DateTime testStartTime = DateTime.now();
  final RxList<double> wpmHistory = <double>[].obs;
  final RxList<double> timePoints = <double>[].obs;
  Timer? _dataCollectionTimer;
RxBool shouldAutoScroll = false.obs;

void scrollToCurrentLine() {
  if (!scrollController.hasClients) return;
  
  double lineHeight = fontSize * 1.3; // Match the line height from the UI
  int prevVisibleLines = 1; // How many previous lines to show
  
  double targetScroll = max(0, (currentLineIndex.value - prevVisibleLines) * lineHeight);
  
  scrollController.animateTo(
    targetScroll,
    duration: const Duration(milliseconds: 150),
    curve: Curves.easeOut,
  );
  shouldAutoScroll.value = false;
}
  @override
  void onInit() {
    super.onInit();
    generateNewTest();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _dataCollectionTimer?.cancel();
    textFieldController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Initialize lines based on target text and container width
  void initializeLines(String targetText, double width) {
    containerWidth = width;
    lines.clear();
    _splitTextIntoLines(targetText);
    currentLineIndex.value = 0;
  }

  // Split target text into lines based on width
  void _splitTextIntoLines(String text) {
  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: '',
      style: TextStyle(
        fontSize: fontSize, // Use the MonkeyType-like font size
        fontFamily: 'RobotoMono',
        height: 1.3, // Use smaller line height
      ),
    ),
  );

  lines.clear();
  String currentLine = '';
  String currentWord = '';

  // Handle word wrapping more elegantly
  for (int i = 0; i < text.length; i++) {
    String char = text[i];
    currentWord += char;

    // Check if we have a complete word
    if (char == ' ' || char == '\n' || i == text.length - 1) {
      // Try adding the word to the current line
      String testLine = currentLine + currentWord;

      textPainter.text = TextSpan(
        text: testLine,
        style: TextStyle(
          fontSize: fontSize, // Use the MonkeyType-like font size
          fontFamily: 'RobotoMono',
          height: 1.3, // Use smaller line height
        ),
      );

      textPainter.layout(maxWidth: containerWidth);

      // If word makes line too long and it's not the only word on the line
      if (textPainter.width > containerWidth && currentLine.isNotEmpty) {
        // Add the current line to our lines list
        lines.add(currentLine.trim());
        // Start a new line with this word
        currentLine = currentWord;
      } else {
        // Word fits, add it to the current line
        currentLine = testLine;
      }

      // Reset for next word
      currentWord = '';
    }
  }

  // Add any remaining text as the last line
  if (currentLine.isNotEmpty) {
    lines.add(currentLine.trim());
  }
}
  Future<void> generateNewTest() async {
    typedText.value = '';
    isTestComplete.value = false;
    isTestActive.value = false;
    correctChars.value = 0;
    incorrectChars.value = 0;
    timeLeft.value = testDuration.value;
    wpm.value = 0.0;
    accuracy.value = 100.0;
    cursorPosition.value = 0;
    currentLineIndex.value = 0;
    lines.clear();
    textFieldController.clear();

    await _generateTextForMode();
    if (containerWidth > 0) {
      initializeLines(currentText.value, containerWidth);
    }
  }

  void updateContainerWidth(double width) {
    if (containerWidth != width) {
      containerWidth = width;
      if (currentText.value.isNotEmpty) {
        initializeLines(currentText.value, containerWidth);
      }
    }
  }

  Future<void> _generateTextForMode() async {
    
    switch (testMode.value) {
      case TestMode.punctuation:
        currentText.value = quoteService.generatePunctuationText(
          _getWordCountForLength(),
        );
        break;
      case TestMode.numbers:
        currentText.value = quoteService.generateNumberText(
          _getWordCountForLength(),
        );
        break;
      case TestMode.time:
        currentText.value = quoteService.generateWordsText(
          _getWordCountForLength(),
        );
        break;
      case TestMode.words:
        currentText.value = quoteService.generateWordsText(
          _getWordCountForLength(),
        );
        break;
      case TestMode.quote:
        Quote quote;
        if (selectedLength.value == 'all') {
          quote = await quoteService.getRandomQuote();
        } else {
          quote = await quoteService.getQuoteByLength(selectedLength.value);
        }
        currentText.value = quote.text;
        break;
      case TestMode.zen:
        currentText.value = quoteService.generateWordsText(100);
        break;
      case TestMode.custom:
        currentText.value = "The quick brown fox jumps over the lazy dog";
        break;
    }
  }

  int _getWordCountForLength() {
     
    switch (selectedLength.value) {
      case 'short':
        return 25;
      case 'medium':
        return 50;
      case 'long':
        return 75;
      case 'thicc':
        return 100;
      default:
        return 25;
    }
  }

  void setTestMode(TestMode mode) {
    testMode.value = mode;
    generateNewTest();
  }

  void setLength(String length) {
    selectedLength.value = length;
    generateNewTest();
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
    int previousLineIndex = currentLineIndex.value;
    typedText.value = value;
    cursorPosition.value = value.length;

    // Calculate which line we're on based on typed characters
    int charsTyped = value.length;
    int totalChars = 0;
    int newLineIndex = 0;

    // Find which line contains the cursor
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      totalChars += line.length;

      if (charsTyped <= totalChars) {
        newLineIndex = i;
        break;
      }

      newLineIndex = i;
    }

    // Only update if the line changed
    if (newLineIndex != currentLineIndex.value) {
      currentLineIndex.value = newLineIndex;
      shouldAutoScroll.value = true; // Trigger scroll animation
    }

    _checkAccuracy();

    // Check if we've completed the test
    if (value.length >= currentText.value.length) {
      endTest();
    }
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
     
    wpmHistory.clear();
    timePoints.clear();

    _dataCollectionTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      final elapsedTimeMinutes = timer.tick * 0.5 / 60;
      if (elapsedTimeMinutes > 0) {
        final currentCorrectChars = _countCorrectChars();
        final currentWpm = (currentCorrectChars / 5) / elapsedTimeMinutes;

        wpmHistory.add(currentWpm);
        timePoints.add(elapsedTimeMinutes * 60);
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
