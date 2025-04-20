// lib/models/test_mode.dart
enum TestMode {
  punctuation,
  numbers,
  time,
  words,
  quote,
  zen,
  custom
}

extension TestModeExtension on TestMode {
  String get displayName {
    switch (this) {
      case TestMode.punctuation:
        return 'Punctuation';
      case TestMode.numbers:
        return 'Numbers';
      case TestMode.time:
        return 'Time';
      case TestMode.words:
        return 'Words';
      case TestMode.quote:
        return 'Quote';
      case TestMode.zen:
        return 'Zen';
      case TestMode.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case TestMode.punctuation:
        return '@';
      case TestMode.numbers:
        return '#';
      case TestMode.time:
        return 'timer_outlined';
      case TestMode.words:
        return 'A';
      case TestMode.quote:
        return 'format_quote';
      case TestMode.zen:
        return 'self_improvement';
      case TestMode.custom:
        return 'edit';
    }
  }

  bool get isIcon {
    switch (this) {
      case TestMode.punctuation:
      case TestMode.numbers:
      case TestMode.words:
        return false;
      case TestMode.time:
      case TestMode.quote:
      case TestMode.zen:
      case TestMode.custom:
        return true;
    }
  }
}