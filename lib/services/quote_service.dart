// lib/services/quote_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});
}

class QuoteService extends GetxService {
  final String apiKey = dotenv.env['API_KEY']!; // Replace with your Rapid API key
  static const String apiHost = 'quotes15.p.rapidapi.com';
  static const String apiUrl = 'https://quotes15.p.rapidapi.com/quotes/random/';

  Future<Quote> getRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-RapidAPI-Key': apiKey, 'X-RapidAPI-Host': apiHost},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Quote(
          text: data['content'],
          author: data['originator']['name'] ?? 'Unknown',
        );
      } else {
        // If API fails, return a default quote
        return Quote(
          text: 'The quick brown fox jumps over the lazy dog',
          author: 'Default',
        );
      }
    } catch (e) {
      // If any error occurs, return a default quote
      return Quote(
        text: 'The quick brown fox jumps over the lazy dog',
        author: 'Default',
      );
    }
  }

  // Method to get quotes with specified criteria (like length)
  Future<Quote> getQuoteByLength(String length) async {
    // length can be "short", "medium", "long"
    try {
      // You would need to adapt this to your actual API endpoint
      final response = await http.get(
        Uri.parse('$apiUrl?length=$length'),
        headers: {'X-RapidAPI-Key': apiKey, 'X-RapidAPI-Host': apiHost},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Quote(
          text: data['content'],
          author: data['originator']['name'] ?? 'Unknown',
        );
      } else {
        return getRandomQuote();
      }
    } catch (e) {
      return getRandomQuote();
    }
  }

  // Method to generate text with punctuation
  String generatePunctuationText(int wordCount) {
    List<String> sentences = [
      "Hello, world! How are you today?",
      "The cat, tired and hungry, meowed loudly.",
      "Wait - did you hear that? I think someone's at the door!",
      "She said, \"I'll be there at 3 p.m.; don't be late.\"",
      "Is this the right way? I'm not sure.",
      "No! Don't touch that; it's extremely fragile.",
      "We need eggs, milk, bread, and cheese from the store.",
      "The movie was great: action-packed, well-acted, and thrilling!",
      "After the storm passed, a rainbow appeared.",
      "When was the last time you visited your grandparents?",
    ];

    sentences.shuffle();
    String result = sentences.join(" ");

    // Trim to approximate word count
    List<String> words = result.split(" ");
    if (words.length > wordCount) {
      words = words.sublist(0, wordCount);
      result = words.join(" ");
    }

    return result;
  }

  // Method to generate text with numbers
  String generateNumberText(int wordCount) {
    List<String> sentences = [
      "There are 365 days in a year and 12 months.",
      "She scored 98 out of 100 on her test.",
      "The apartment is on the 7th floor of building 23.",
      "It costs ${49.99} plus 8.5% tax.",
      "The temperature today is 72°F or about 22°C.",
      "The odds are 5 to 1 against winning.",
      "My phone number is 555-123-4567.",
      "The recipe calls for 2 cups of flour and 3 tablespoons of sugar.",
      "The train arrives at 10:45 AM on track 6.",
      "There are 60 seconds in a minute and 60 minutes in an hour.",
    ];

    sentences.shuffle();
    String result = sentences.join(" ");

    // Trim to approximate word count
    List<String> words = result.split(" ");
    if (words.length > wordCount) {
      words = words.sublist(0, wordCount);
      result = words.join(" ");
    }

    return result;
  }

  // Generate text for words mode (common English words)
  String generateWordsText(int wordCount) {
    List<String> commonWords = [
      "the",
      "be",
      "to",
      "of",
      "and",
      "a",
      "in",
      "that",
      "have",
      "I",
      "it",
      "for",
      "not",
      "on",
      "with",
      "he",
      "as",
      "you",
      "do",
      "at",
      "this",
      "but",
      "his",
      "by",
      "from",
      "they",
      "we",
      "say",
      "her",
      "she",
      "or",
      "an",
      "will",
      "my",
      "one",
      "all",
      "would",
      "there",
      "their",
      "what",
      "so",
      "up",
      "out",
      "if",
      "about",
      "who",
      "get",
      "which",
      "go",
      "me",
    ];

    List<String> result = [];
    for (int i = 0; i < wordCount; i++) {
      result.add(commonWords[i % commonWords.length]);
    }

    return result.join(" ");
  }
}
