import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  var isDarkMode = true.obs; // Default to dark mode like MonkeyType

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    getSavedThemeMode();
  }

  Future<void> getSavedThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode.value =
        prefs.getBool('isDarkMode') ?? true; // Default to dark mode
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(themeMode);
  }
}
