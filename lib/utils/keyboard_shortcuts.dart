// lib/utils/keyboard_shortcuts.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:monkeytype_clone/models/test_mode.dart';
import '../controllers/typing_test_controller.dart';

class KeyboardShortcutsHandler extends StatefulWidget {
  final Widget child;
  final TypingTestController controller;

  const KeyboardShortcutsHandler({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  _KeyboardShortcutsHandlerState createState() => _KeyboardShortcutsHandlerState();
}

class _KeyboardShortcutsHandlerState extends State<KeyboardShortcutsHandler> {
  // Track key states
  bool isTabPressed = false;
  bool isEnterPressed = false;
  bool isEscapePressed = false;
  bool isCommandPressed = false;
  bool isShiftPressed = false;
  bool isPPressed = false;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        // Handle key down
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.tab:
              isTabPressed = true;
              break;
            case LogicalKeyboardKey.enter:
              isEnterPressed = true;
              break;
            case LogicalKeyboardKey.escape:
              isEscapePressed = true;
              _handleCommandLine();
              break;
            case LogicalKeyboardKey.meta:
            case LogicalKeyboardKey.controlLeft:
            case LogicalKeyboardKey.controlRight:
              isCommandPressed = true;
              break;
            case LogicalKeyboardKey.shiftLeft:
            case LogicalKeyboardKey.shiftRight:
              isShiftPressed = true;
              break;
            case LogicalKeyboardKey.keyP:
              isPPressed = true;
              break;
          }
          
          // Check for Tab + Enter combination (restart test)
          if (isTabPressed && isEnterPressed) {
            widget.controller.restartTest();
            isTabPressed = false;
            isEnterPressed = false;
          }
          
          // Check for Command + Shift + P combination (command line)
          if (isCommandPressed && isShiftPressed && isPPressed) {
            _handleCommandLine();
            isCommandPressed = false;
            isShiftPressed = false;
            isPPressed = false;
          }
        }
        
        // Handle key up
        if (event is KeyUpEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.tab:
              isTabPressed = false;
              break;
            case LogicalKeyboardKey.enter:
              isEnterPressed = false;
              break;
            case LogicalKeyboardKey.escape:
              isEscapePressed = false;
              break;
            case LogicalKeyboardKey.meta:
            case LogicalKeyboardKey.controlLeft:
            case LogicalKeyboardKey.controlRight:
              isCommandPressed = false;
              break;
            case LogicalKeyboardKey.shiftLeft:
            case LogicalKeyboardKey.shiftRight:
              isShiftPressed = false;
              break;
            case LogicalKeyboardKey.keyP:
              isPPressed = false;
              break;
          }
        }
      },
      child: widget.child,
    );
  }

  void _handleCommandLine() {
    // Show the command line dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController commandController = TextEditingController();
        
        return AlertDialog(
          backgroundColor: const Color(0xFF232427),
          title: Text(
            'Command Line',
            style: TextStyle(color: Colors.white70),
          ),
          content: TextField(
            controller: commandController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Type a command...',
              hintStyle: TextStyle(color: Colors.white30),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber, width: 2),
              ),
            ),
            style: TextStyle(color: Colors.white),
            onSubmitted: (String command) {
              _processCommand(command.toLowerCase());
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.amber)),
            ),
            ElevatedButton(
              onPressed: () {
                _processCommand(commandController.text.toLowerCase());
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: Text('Execute', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _processCommand(String command) {
    // Process the command
    if (command == 'restart' || command == 'reset') {
      widget.controller.restartTest();
    } else if (command.startsWith('time ')) {
      // Parse time command like "time 30" for 30 seconds
      try {
        final seconds = int.parse(command.split(' ')[1]);
        widget.controller.setTestDuration(seconds);
      } catch (e) {
        // Invalid time format
      }
    } else if (command.startsWith('words ')) {
      // Parse words command like "words 50" for 50 words
      try {
        final wordCount = int.parse(command.split(' ')[1]);
        widget.controller.wordCount.value = wordCount;
        widget.controller.generateNewTest();
      } catch (e) {
        // Invalid word count format
      }
    } else if (command == 'quote') {
      widget.controller.setTestMode(TestMode.quote);
    } else if (command == 'zen') {
      widget.controller.setTestMode(TestMode.zen);
    }
    // Add more commands as needed
  }
}