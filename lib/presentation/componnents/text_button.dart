
import 'package:flutter/material.dart';
import 'package:fruit_detect/core/themes/colors.dart';
import 'package:fruit_detect/core/themes/text_themes.dart';

class KButton extends StatelessWidget {
    final String text;
  const KButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        color: kRed,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          text,
          style: h1.copyWith(color: kWhite),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}