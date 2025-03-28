// ignore_for_file: prefer_const_constructors

import 'package:yolo_realtime_plugin/yolo_realtime_plugin.dart';
import 'package:flutter/material.dart';
import 'dart:async';


class Realtime extends StatefulWidget {
  const Realtime({super.key});

  @override
  State<Realtime> createState() => _RealtimeState();
}

class _RealtimeState extends State<Realtime> {
  @override
  Widget build(BuildContext context) {
    return YoloRealTimeViewExample();
  }
}

class YoloRealTimeViewExample extends StatefulWidget {
  const YoloRealTimeViewExample({Key? key}) : super(key: key);

  @override
  State<YoloRealTimeViewExample> createState() =>
      _YoloRealTimeViewExampleState();
}

class _YoloRealTimeViewExampleState extends State<YoloRealTimeViewExample> {
  YoloRealtimeController? yoloController;

  @override
  void initState() {
    super.initState();

    yoloInit();
  }

  Future<void> yoloInit() async {
    yoloController = YoloRealtimeController(
      // common
      fullClasses: fullClasses,
      activeClasses: activeClasses,

      // android
      androidModelPath: 'assets/models/best.pt',
      androidModelWidth: 640,
      androidModelHeight: 640,
      androidConfThreshold: 0.5,
      androidIouThreshold: 0.5,

      // ios
      iOSModelPath: 'yolov5s',
      iOSConfThreshold: 0.5,
    );

    try {
      await yoloController?.initialize();
    } catch (e) {
      print('ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (yoloController == null) {
      return Container();
    }

    return YoloRealTimeView(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      controller: yoloController!,
      drawBox: true,
      captureBox: (boxes) {
        // print(boxes);
      },
      captureImage: (data) async {
        // print('binary image: $data');

        /// Process and use the binary image as you wish.
        // imageToFile(data);
      },
    );
  }

  // Future<File?> imageToFile(Uint8List? image) async {
  //   File? file;
  //   if (image != null) {
  //     final tempDir = await getTemporaryDirectory();
  //     file = await File('${tempDir.path}/${DateTime.now()}.png').create();
  //     file.writeAsBytesSync(image);
  //
  //     print('File saved: ${file.path}');
  //   }
  //   return file;
  // }

  List<String> activeClasses = [
    "empty_bunch_palm",
"overripe_palm",
"ripe_apple",
"ripe_banana",
"ripe_dragon",
"ripe_grapes",
"ripe_lemon",
"ripe_mango",
"ripe_orange",
"ripe_palm",
"ripe_papaya",
"ripe_pineapple",
"ripe_pomegranate",
"ripe_strawberry",
"rotten_palm",
"underripe_palm",
"unripe_apple",
"unripe_banana",
"unripe_dragon",
"unripe_grapes",
"unripe_lemon",
"unripe_mango",
"unripe_orange",
"unripe_palm",
"unripe_papaya",
"unripe_pineapple",
"unripe_pomegranate",
"unripe_strawberry"
  ];

  List<String> fullClasses = [
    "empty_bunch_palm",
"overripe_palm",
"ripe_apple",
"ripe_banana",
"ripe_dragon",
"ripe_grapes",
"ripe_lemon",
"ripe_mango",
"ripe_orange",
"ripe_palm",
"ripe_papaya",
"ripe_pineapple",
"ripe_pomegranate",
"ripe_strawberry",
"rotten_palm",
"underripe_palm",
"unripe_apple",
"unripe_banana",
"unripe_dragon",
"unripe_grapes",
"unripe_lemon",
"unripe_mango",
"unripe_orange",
"unripe_palm",
"unripe_papaya",
"unripe_pineapple",
"unripe_pomegranate",
"unripe_strawberry"
  ];
}