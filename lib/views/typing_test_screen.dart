// lib/screens/typing_test_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/theme_controller.dart';
import '../controllers/typing_test_controller.dart';
import '../models/test_mode.dart';
import '../widgets/result_dialog.dart';
import '../utils/keyboard_shortcuts.dart';

class TypingTestScreen extends StatelessWidget {
  final TypingTestController typingController = Get.put(TypingTestController());
  final ThemeController themeController = Get.find();
  final FocusNode _focusNode = FocusNode();

  TypingTestScreen({super.key});

  TextStyle monoTextStyle({
    double fontSize = 28,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final bool isMediumScreen =
        screenSize.width >= 600 && screenSize.width < 900;
    final bool isLargeScreen = screenSize.width >= 900;

    // Adjust font sizes based on screen size
    final double headerFontSize =
        isSmallScreen ? 14 : (isMediumScreen ? 16 : 18);
    final double textFontSize = isSmallScreen ? 32 : (isMediumScreen ? 32 : 48);
    final double optionFontSize = isSmallScreen ? 12 : 14;

    return KeyboardShortcutsHandler(
      controller: typingController,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 58, 58, 61),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: AppBar(
            forceMaterialTransparency: true,
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'MonkeyType Clone',
              style: monoTextStyle(
                fontSize: headerFontSize,
                color: Colors.white70,
              ),
            ),
            backgroundColor: const Color(0xFF232427),
            elevation: 0,

            actions: [
              IconButton(
                icon: const Icon(
                  Icons.keyboard,
                  size: 18,
                  color: Colors.white30,
                ),
                onPressed: () {},
              ),
              if (!isSmallScreen)
                IconButton(
                  icon: const Icon(
                    Icons.star_border,
                    size: 18,
                    color: Colors.white30,
                  ),
                  onPressed: () {},
                ),
              if (!isSmallScreen)
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.white30,
                  ),
                  onPressed: () {},
                ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: Colors.white30,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 800 : double.infinity,
              ),
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildTestOptions(optionFontSize),
                  const SizedBox(height: 16),
                  _buildLengthOptions(optionFontSize),
                  SizedBox(height: isSmallScreen ? 16 : 32),
                  _buildLanguageSelector(optionFontSize),
                  SizedBox(height: isSmallScreen ? 16 : 32),
                  _buildTypingArea(context),
                  const SizedBox(height: 24),
                  _buildRestartButton(),
                  const Spacer(),
                  if (!isSmallScreen) _buildKeyboardShortcuts(),
                  const SizedBox(height: 16),
                  _buildFooter(isSmallScreen),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestOptions(double fontSize) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2E31),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children:
              TestMode.values
                  .map(
                    (mode) => _buildOptionButton(
                      mode.icon,
                      mode.displayName,
                      isIcon: mode.isIcon,
                      isHighlighted: typingController.testMode.value == mode,
                      onPressed: () => typingController.setTestMode(mode),
                      fontSize: fontSize,
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    String iconOrText,
    String label, {
    bool isIcon = false,
    bool isHighlighted = false,
    VoidCallback? onPressed,
    double fontSize = 14,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isIcon
              ? Icon(
                getIconData(iconOrText),
                size: fontSize + 2,
                color: isHighlighted ? const Color(0xFFE2B714) : Colors.white30,
              )
              : Text(
                iconOrText,
                style: monoTextStyle(
                  fontSize: fontSize,
                  color:
                      isHighlighted ? const Color(0xFFE2B714) : Colors.white30,
                ),
              ),
          const SizedBox(width: 4),
          Text(
            label,
            style: monoTextStyle(
              fontSize: fontSize,
              color: isHighlighted ? const Color(0xFFE2B714) : Colors.white30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLengthOptions(double fontSize) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2E31),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildLengthButton(
              'all',
              typingController.selectedLength.value == 'all',
              fontSize,
            ),
            _buildLengthButton(
              'short',
              typingController.selectedLength.value == 'short',
              fontSize,
            ),
            _buildLengthButton(
              'medium',
              typingController.selectedLength.value == 'medium',
              fontSize,
            ),
            _buildLengthButton(
              'long',
              typingController.selectedLength.value == 'long',
              fontSize,
            ),
            _buildLengthButton(
              'thicc',
              typingController.selectedLength.value == 'thicc',
              fontSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLengthButton(String label, bool isSelected, double fontSize) {
    return TextButton(
      onPressed: () => typingController.setLength(label),
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        label,
        style: monoTextStyle(
          fontSize: fontSize,
          color: isSelected ? const Color(0xFFE2B714) : Colors.white30,
        ),
      ),
    );
  }

  IconData getIconData(String iconName) {
    switch (iconName) {
      case 'timer_outlined':
        return Icons.timer_outlined;
      case 'format_quote':
        return Icons.format_quote;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'edit':
        return Icons.edit;
      default:
        return Icons.error;
    }
  }

  Widget _buildLanguageSelector(double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language, size: fontSize + 2, color: Colors.white30),
          const SizedBox(width: 8),
          Text(
            'english',
            style: monoTextStyle(fontSize: fontSize, color: Colors.white70),
          ),
        ],
      ),
    );
  }

Widget _buildTypingArea(BuildContext context) {
  // Use smaller font size like MonkeyType
  final double fontSize = 18.0;
  
  return Obx(() {
    final typingController = Get.find<TypingTestController>();

    if (typingController.isTestComplete.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(context: context, builder: (context) => ResultsScreen());
      });
    }

    String targetText = typingController.currentText.value;
    String typed = typingController.typedText.value;
    int currentLineIndex = typingController.currentLineIndex.value;

    // Calculate container width and update controller
    double containerWidth = MediaQuery.of(context).size.width - 48;
    typingController.updateContainerWidth(containerWidth);

    // Handle empty lines case
    if (typingController.lines.isEmpty && targetText.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Loading text...",
            style: TextStyle(color: Colors.white60),
          ),
        ],
      );
    }

    // Calculate visible lines like MonkeyType
    List<Widget> visibleLines = [];
    
    // Show more lines like MonkeyType (2 previous, current, 3 next for more context)
    int firstVisibleLine = max(0, currentLineIndex - 2);
    int lastVisibleLine = min(typingController.lines.length - 1, currentLineIndex + 3);

    // Calculate starting character indices
    Map<int, int> lineStartIndices = {};
    int charCount = 0;
    
    for (int i = 0; i < typingController.lines.length; i++) {
      lineStartIndices[i] = charCount;
      charCount += typingController.lines[i].length;
    }

    // Create each visible line with proper styling
    for (int i = firstVisibleLine; i <= lastVisibleLine; i++) {
      String line = typingController.lines[i];
      int lineStartIndex = lineStartIndices[i] ?? 0;
      
      // Determine typed text for this line
      String typedForLine = '';
      if (typed.length > lineStartIndex) {
        typedForLine = typed.substring(
          lineStartIndex,
          min(typed.length, lineStartIndex + line.length),
        );
      }

      // Calculate opacity based on distance from current line (MonkeyType style)
      double opacity;
      if (i == currentLineIndex) {
        opacity = 0.9; // Current line - most visible
      } else if (i < currentLineIndex) {
        opacity = 0.3; // Previous lines - dimmed
      } else {
        // Next lines - decreasing opacity as they get further away
        opacity = 0.6 - ((i - currentLineIndex) * 0.1);
        opacity = max(0.2, opacity); // Don't go below 0.2
      }
      
      visibleLines.add(
        RichText(
          text: TextSpan(
            children: _buildTextSpans(
              line,
              i == currentLineIndex ? typedForLine : (i < currentLineIndex ? line : ''),
              fontSize,
            ),
            style: monoTextStyle(
              fontSize: fontSize,
              color: Colors.white.withOpacity(opacity),
              // height: 1.3, // Reduced line height for MonkeyType feel
            ),
          ),
        ),
      );
    }

    // Handle automatic scrolling for smooth line transitions
    if (typingController.shouldAutoScroll.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        typingController.scrollToCurrentLine();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress counter (smaller and more subtle like MonkeyType)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "${typed.length}/${targetText.length}",
            style: monoTextStyle(
              color: Colors.amber.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4), // Reduced spacing

        // Typing area with proper height calculation
        SizedBox(
          height: fontSize * 1.3 * 6, // Height for visible lines (fits up to 6 lines)
          child: Stack(
            children: [
              // Text display area
              SingleChildScrollView(
                controller: typingController.scrollController,
                physics: const NeverScrollableScrollPhysics(), // Disable manual scrolling
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: visibleLines,
                  ),
                ),
              ),
              
              // Invisible text field for capturing input
              Positioned.fill(
                child: TextField(
                  controller: typingController.textFieldController,
                  onChanged: typingController.checkTypedText,
                  focusNode: _focusNode, // Make sure this is defined in your class
                  autofocus: true,
                  cursorColor: Colors.amber.withOpacity(0.7), // MonkeyType-style cursor
                  cursorWidth: 2,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                  ),
                  style: monoTextStyle(
                    color: Colors.transparent,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  });
}

List<TextSpan> _buildTextSpans(
  String targetText,
  String typed,
  double fontSize,
) {
  List<TextSpan> spans = [];

  for (int i = 0; i < targetText.length; i++) {
    Color color;
    Color? backgroundColor;
    
    if (i < typed.length) {
      if (typed[i] != targetText[i]) {
        // Incorrect character - red with subtle background
        color = const Color(0xFFe06c75);
        backgroundColor = const Color(0x30e06c75); // More subtle background
      } else {
        // Correct character - white
        color = Colors.white;
        backgroundColor = null;
      }
    } else if (i == typed.length) {
      // Current cursor position - amber with subtle background
      color = Colors.amber;
      backgroundColor = Colors.white10;
    } else {
      // Not typed yet - dimmed
      color = Colors.white30;
      backgroundColor = null;
    }

    spans.add(
      TextSpan(
        text: targetText[i],
        style: monoTextStyle(
          fontSize: fontSize,
          color: color,
        ),
      ),
    );
  }

  return spans;
}
  Widget _buildRestartButton() {
    return IconButton(
      onPressed: () => typingController.restartTest(),
      icon: const Icon(Icons.refresh, color: Colors.white30, size: 24),
    );
  }

  Widget _buildKeyboardShortcuts() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShortcutButton("tab"),
          Text(
            " + ",
            style: monoTextStyle(color: Colors.white30, fontSize: 12),
          ),
          _buildShortcutButton("enter"),
          Text(
            " - restart test",
            style: monoTextStyle(color: Colors.white30, fontSize: 12),
          ),
          const SizedBox(width: 20),
          _buildShortcutButton("esc"),
          Text(
            " or ",
            style: monoTextStyle(color: Colors.white30, fontSize: 12),
          ),
          _buildShortcutButton("cmd"),
          Text(
            " + ",
            style: monoTextStyle(color: Colors.white30, fontSize: 12),
          ),
          _buildShortcutButton("shift"),
          Text(
            " + ",
            style: monoTextStyle(color: Colors.white30, fontSize: 12),
          ),
          _buildShortcutButton("p"),
          Text(
            " - command line",
            style: monoTextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2E31),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: monoTextStyle(color: Colors.white54, fontSize: 12),
      ),
    );
  }

  Widget _buildFooter(bool isSmallScreen) {
    return isSmallScreen
        ? Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFooterLink(Icons.email, "contact"),
                _buildFooterLink(Icons.support, "support"),
                _buildFooterLink(Icons.code, "github"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.brightness_2, size: 14, color: Colors.white30),
                Text(
                  " serika dark ",
                  style: monoTextStyle(color: Colors.white30, fontSize: 12),
                ),
                Text(
                  "v25.16.1",
                  style: monoTextStyle(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
          ],
        )
        : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildFooterLink(Icons.email, "contact"),
                _buildFooterLink(Icons.support, "support"),
                _buildFooterLink(Icons.code, "github"),
                _buildFooterLink(Icons.discord, "discord"),
                _buildFooterLink(null, "terms"),
                _buildFooterLink(null, "security"),
                _buildFooterLink(null, "privacy"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.brightness_2, size: 14, color: Colors.white30),
                Text(
                  " serika dark ",
                  style: monoTextStyle(color: Colors.white30, fontSize: 12),
                ),
                Text(
                  "v25.16.1",
                  style: monoTextStyle(color: Colors.white30, fontSize: 12),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "new",
                    style: monoTextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
  }

  Widget _buildFooterLink(IconData? icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 14, color: Colors.white30),
          if (icon != null) const SizedBox(width: 4),
          Text(text, style: monoTextStyle(color: Colors.white30, fontSize: 12)),
        ],
      ),
    );
  }
}
