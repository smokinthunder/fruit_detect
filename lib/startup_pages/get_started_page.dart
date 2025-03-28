import 'package:flutter/material.dart';
import 'package:fruit_detect/core/themes/colors.dart';
import 'package:fruit_detect/core/themes/text_themes.dart';
import 'package:fruit_detect/main.dart';
import 'package:fruit_detect/presentation/componnents/text_button.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset('assets/images/cover.jpg', fit: BoxFit.cover),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0x80000000),
          ),
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Welcome to the Fruit Detect App",
                  style: mtitle.copyWith(color: kWhite),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Detect fruits here",
                  style: parah.copyWith(color: kWhite70),
                  textAlign: TextAlign.center,
                ),
                Gap(60),
                InkWell(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool("skipOnBoarding", true);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MyApp(skipOnBoarding: true),
                      ),
                    );
                  },
                  child: KButton(text: "Get Started"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
