import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/theme_controller.dart';
import '../controllers/typing_test_controller.dart';
import '../widgets/result_dialog.dart';

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

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 58, 58, 61),
      appBar: PreferredSize(
      
        preferredSize: const Size.fromHeight(48),
        child: AppBar(
          forceMaterialTransparency: true,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Monkeytype Clone',
            style: monoTextStyle(fontSize: 18, color: Colors.white70),
          ),
          backgroundColor: const Color(0xFF232427),
          elevation: 0,
         
          actions: [
            IconButton(
              icon: const Icon(Icons.keyboard, size: 18, color: Colors.white30),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.star_border, size: 18, color: Colors.white30),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 18, color: Colors.white30),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, size: 18, color: Colors.white30),
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
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildTestOptions(),
                const SizedBox(height: 100),
                _buildLanguageSelector(),
                const SizedBox(height: 32),
                _buildTypingArea(),
                const SizedBox(height: 40),
                _buildRestartButton(),
                const Spacer(),
                _buildKeyboardShortcuts(),
                const SizedBox(height: 20),
                _buildFooter(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestOptions() {
    return Container(
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
          _buildOptionButton("@", "punctuation"),
          _buildOptionButton("#", "numbers"),
          _buildOptionButton("timer_outlined", "time", isIcon: true),
          _buildOptionButton("A", "words"),
          _buildOptionButton("format_quote", "quote", isIcon: true),
          _buildOptionButton("self_improvement", "zen", isIcon: true),
          _buildOptionButton("edit", "custom", isIcon: true, isHighlighted: true),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String iconOrText, String label,
      {bool isIcon = false, bool isHighlighted = false}) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isIcon
              ? Icon(
                  getIconData(iconOrText),
                  size: 16,
                  color: isHighlighted ? const Color(0xFFE2B714) : Colors.white30,
                )
              : Text(
                  iconOrText,
                  style: monoTextStyle(
                    fontSize: 14,
                    color: isHighlighted ? const Color(0xFFE2B714) : Colors.white30,
                  ),
                ),
          const SizedBox(width: 6),
          Text(
            label,
            style: monoTextStyle(
              fontSize: 14,
              color: isHighlighted ? const Color(0xFFE2B714) : Colors.white30,
            ),
          ),
        ],
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

  Widget _buildLanguageSelector() {
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
          const Icon(Icons.language, size: 16, color: Colors.white30),
          const SizedBox(width: 8),
          Text('english', style: monoTextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

Widget _buildTypingArea() {
  return Obx(() {
    if (typingController.isTestComplete.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Replace this dialog code:
        // showDialog(
        //   context: Get.context!,
        //   builder: (context) => ResultsDialog(),
        // );
        
        // With navigation to the results screen:
        Get.to(() => ResultsScreen());
      });
    }

    String targetText = typingController.currentText.value;
    String typed = typingController.typedText.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text("${typed.length}/${targetText.length}", style: monoTextStyle(color: Colors.amber, fontSize: 32)),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // The visible styled text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  children: _buildTextSpans(targetText, typed),
                  style: monoTextStyle(fontSize: 48, color: Colors.white54).copyWith(height: 1.5),
                ),
              ),
            ),
        
            // Transparent TextField on top
            TextField(
              controller: typingController.textFieldController,
              onChanged: typingController.checkTypedText,
              focusNode: _focusNode,
              autofocus: true,
              cursorColor: Colors.transparent, // Hide blinking cursor
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(
                color: Colors.transparent, // Hide typed text
                fontSize: 28,
                fontFamily: 'RobotoMono',
                height: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  });
}


  List<TextSpan> _buildTextSpans(String targetText, String typed) {
    List<TextSpan> spans = [];

    for (int i = 0; i < targetText.length; i++) {
      if (i < typed.length && typed[i] != targetText[i]) {
        spans.add(TextSpan(
          text: targetText[i],
          style: monoTextStyle(color: const Color(0xFFe06c75)).copyWith(
            backgroundColor: const Color(0x40e06c75),
          ),
        ));
      } else if (i < typed.length) {
        spans.add(TextSpan(
          text: targetText[i],
          style: monoTextStyle(color: Colors.white),
        ));
      } else if (i == typed.length) {
        spans.add(TextSpan(
          text: targetText[i],
          style: monoTextStyle(color: Colors.amber).copyWith(backgroundColor: Colors.white10),
        ));
      } else {
        spans.add(TextSpan(
          text: targetText[i],
          style: monoTextStyle(color: Colors.white30),
        ));
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildShortcutButton("tab"),
        Text(" + ", style: monoTextStyle(color: Colors.white30, fontSize: 12)),
        _buildShortcutButton("enter"),
        Text(" - restart test", style: monoTextStyle(color: Colors.white30, fontSize: 12)),
        const SizedBox(width: 20),
        _buildShortcutButton("esc"),
        Text(" or ", style: monoTextStyle(color: Colors.white30, fontSize: 12)),
        _buildShortcutButton("cmd"),
        Text(" + ", style: monoTextStyle(color: Colors.white30, fontSize: 12)),
        _buildShortcutButton("shift"),
        Text(" + ", style: monoTextStyle(color: Colors.white30, fontSize: 12)),
        _buildShortcutButton("p"),
        Text(" - command line", style: monoTextStyle(color: Colors.white30, fontSize: 12)),
      ],
    );
  }

  Widget _buildShortcutButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2E31),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: monoTextStyle(color: Colors.white54, fontSize: 12)),
    );
  }

  Widget _buildFooter() {
    return Row(
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
            Text(" serika dark ", style: monoTextStyle(color: Colors.white30, fontSize: 12)),
            Text("v25.16.1", style: monoTextStyle(color: Colors.white30, fontSize: 12)),
            Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "new",
                style: monoTextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
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
