import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class ThemeSelector extends StatelessWidget {
  final ThemeController themeController = Get.find();

  ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        icon: Icon(
          themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
          color: themeController.isDarkMode.value ? Colors.white : Colors.black,
        ),
        onPressed: () {
          themeController.toggleTheme();
        },
      ),
    );
  }
}
