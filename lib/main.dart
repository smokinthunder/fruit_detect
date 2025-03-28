import 'package:flutter/material.dart';
import 'package:fruit_detect/presentation/home/home_page.dart';
import 'package:fruit_detect/startup_pages/get_started_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final skipOnBoarding = prefs.getBool("skipOnBoarding") ?? false;
  // final skipOnBoarding =  true;
  

  runApp(MyApp(skipOnBoarding: skipOnBoarding,));
}

class MyApp extends StatelessWidget {
  final bool skipOnBoarding;
  const MyApp({super.key, required this.skipOnBoarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: skipOnBoarding ? HomePage() : GetStartedPage(),
    );
  }
}