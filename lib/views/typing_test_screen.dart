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
    final double textFontSize = isSmallScreen ? 32 : (isMediumScreen ? 40 : 48);
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
                  _buildTypingArea(context, textFontSize),
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

  Widget _buildTypingArea(BuildContext context, double fontSize) {
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
        // Existing fallback code
        return Column(/* Your existing fallback code */);
      }

      // Calculate visible lines: previous, current, and next line (for smoother transitions)
      List<Widget> visibleLines = [];

      // Get indices for previous, current, and next line
      int prevLineIndex = currentLineIndex - 1;
      int nextLineIndex = currentLineIndex + 1;

      // Calculate starting character indices for each line
      int currentLineStartIndex = 0;
      if (currentLineIndex > 0) {
        currentLineStartIndex = typingController.lines
            .sublist(0, currentLineIndex)
            .fold(0, (sum, line) => sum + line.length);
      }

      // Previous line (dimmed)
      if (prevLineIndex >= 0 && prevLineIndex < typingController.lines.length) {
        String prevLine = typingController.lines[prevLineIndex];
        int prevLineStartIndex = currentLineStartIndex - prevLine.length;
        String typedForPrevLine =
            typed.length > prevLineStartIndex
                ? typed.substring(
                  prevLineStartIndex,
                  min(typed.length, prevLineStartIndex + prevLine.length),
                )
                : '';

        visibleLines.add(
          RichText(
            text: TextSpan(
              children: _buildTextSpans(prevLine, typedForPrevLine, fontSize),
              style: monoTextStyle(
                fontSize: fontSize,
                color: Colors.white24, // More dimmed than current
              ).copyWith(height: 1.5),
            ),
          ),
        );
      }

      // Current line (focus)
      if (currentLineIndex < typingController.lines.length) {
        String currentLine = typingController.lines[currentLineIndex];
        String typedForCurrentLine =
            typed.length > currentLineStartIndex
                ? typed.substring(
                  currentLineStartIndex,
                  min(typed.length, currentLineStartIndex + currentLine.length),
                )
                : '';

        visibleLines.add(
          RichText(
            text: TextSpan(
              children: _buildTextSpans(
                currentLine,
                typedForCurrentLine,
                fontSize,
              ),
              style: monoTextStyle(
                fontSize: fontSize,
                color: Colors.white70, // Brighter than previous
              ).copyWith(height: 1.5),
            ),
          ),
        );
      }

      // Next line (slightly dimmed)
      if (nextLineIndex < typingController.lines.length) {
        String nextLine = typingController.lines[nextLineIndex];
        visibleLines.add(
          RichText(
            text: TextSpan(
              children: _buildTextSpans(
                nextLine,
                '', // Not typed yet
                fontSize,
              ),
              style: monoTextStyle(
                fontSize: fontSize,
                color:
                    Colors
                        .white38, // Dimmer than current, brighter than previous
              ).copyWith(height: 1.5),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "${typed.length}/${targetText.length}",
              style: monoTextStyle(
                color: Colors.amber,
                fontSize: fontSize - 16,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Typing area with fixed height for multiple lines
          SizedBox(
            height: fontSize * 1.5 * 3, // Height for 3 lines
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: typingController.scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: visibleLines,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: TextField(
                    controller: typingController.textFieldController,
                    onChanged: typingController.checkTypedText,
                    focusNode: _focusNode,
                    autofocus: true,
                    cursorColor: Colors.transparent,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: TextStyle(
                      color: Colors.transparent,
                      fontSize: fontSize,
                      fontFamily: 'RobotoMono',
                      height: 1.5,
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
      if (i < typed.length && typed[i] != targetText[i]) {
        spans.add(
          TextSpan(
            text: targetText[i],
            style: monoTextStyle(
              fontSize: fontSize,
              color: const Color(0xFFe06c75),
            ).copyWith(backgroundColor: const Color(0x40e06c75)),
          ),
        );
      } else if (i < typed.length) {
        spans.add(
          TextSpan(
            text: targetText[i],
            style: monoTextStyle(fontSize: fontSize, color: Colors.white),
          ),
        );
      } else if (i == typed.length) {
        spans.add(
          TextSpan(
            text: targetText[i],
            style: monoTextStyle(
              fontSize: fontSize,
              color: Colors.amber,
            ).copyWith(backgroundColor: Colors.white10),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: targetText[i],
            style: monoTextStyle(fontSize: fontSize, color: Colors.white30),
          ),
        );
      }
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
