import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:monkeytype_clone/controllers/theme_controller.dart';
import 'package:monkeytype_clone/views/typing_test_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'dotenv.txt');
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(MonkeyTypeClone());
}

class MonkeyTypeClone extends StatelessWidget {
  const MonkeyTypeClone({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return GetMaterialApp(
      title: 'MonkeyType Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.robotoMonoTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
        ),
        appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF2C2E31),
        textTheme: GoogleFonts.robotoMonoTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      themeMode: themeController.themeMode,
      home: TypingTestScreen(),
    );
  }
}
