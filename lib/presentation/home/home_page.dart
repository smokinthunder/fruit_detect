import 'package:flutter/material.dart';
import 'package:fruit_detect/core/themes/colors.dart';
import 'package:fruit_detect/presentation/camera/camera_page.dart';
import 'package:fruit_detect/presentation/camera/live_object_detection.dart';
import 'package:fruit_detect/presentation/camera/realtime.dart';
import 'package:fruit_detect/presentation/componnents/text_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Realtime())),
          child: KButton(text: "Open Camera"))
          ],
      ),
    );
  }
}
