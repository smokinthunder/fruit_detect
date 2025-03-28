import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; // Use tflite_flutter [[1]]
import 'package:image/image.dart' as img;

class LiveObjectDetection extends StatefulWidget {
  @override
  _LiveObjectDetectionState createState() => _LiveObjectDetectionState();
}

class _LiveObjectDetectionState extends State<LiveObjectDetection> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isModelLoaded = false; // Track model loading status [[1]]
  List<dynamic>? _results;
  Interpreter? _interpreter; // Nullable interpreter to avoid late initialization errors [[1]]

  @override
  void initState() {
    super.initState();
    print("Initializing app..."); // Debugging [[7]]
    _initializeCamera();
    _loadModel(); // Load model asynchronously
  }

  Future<void> _initializeCamera() async {
    print("Initializing camera..."); // Debugging [[7]]
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      print("No cameras available."); // Debugging [[7]]
      return;
    }

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );

    try {
      await _cameraController.initialize();
      print("Camera initialized successfully."); // Debugging [[7]]
      setState(() => _isCameraInitialized = true);
      _startDetectionIfReady(); // Start detection only if both camera and model are ready [[1]]
    } catch (e) {
      print("Camera error: $e");
    }
  }

  Future<void> _loadModel() async {
    print("Loading TensorFlow Lite model..."); // Debugging [[7]]
    try {
      _interpreter = await Interpreter.fromAsset("models/best.tflite"); // Initialize interpreter [[1]]
      print("Model loaded successfully."); // Debugging [[7]]
      setState(() => _isModelLoaded = true);
      _startDetectionIfReady(); // Start detection only if both camera and model are ready [[1]]
    } catch (e) {
      print("Model load error: $e");
    }
  }

  void _startDetectionIfReady() {
    if (_isCameraInitialized && _isModelLoaded) {
      print("Both camera and model are ready. Starting object detection..."); // Debugging [[7]]
      _runObjectDetection();
    } else {
      print("Waiting for camera and model to initialize..."); // Debugging [[7]]
    }
  }

  void _runObjectDetection() {
    if (!_isCameraInitialized || !_isModelLoaded) {
      print("Skipping object detection: Camera or model not ready."); // Debugging [[7]]
      return;
    }

    _cameraController.startImageStream((CameraImage image) async {
      try {
        print("Processing new camera frame..."); // Debugging [[7]]
        Float32List input = _preprocessImage(image); // Preprocess image to [1, 640, 640, 3] tensor [[1]]
        print("Preprocessed image: ${input.length} bytes"); // Debugging [[7]]
        var output = _runInference(input); // Run inference with nullable interpreter [[1]]
        print("Inference output: $output"); // Debugging [[7]]
        var results = _postProcessOutput(output);
        print("Post-processed results: $results"); // Debugging [[7]]
        setState(() => _results = results);
      } catch (e) {
        print("Inference error: $e");
      }
    });
  }

  Float32List _preprocessImage(CameraImage image) {
    print("Converting YUV to RGB..."); // Debugging [[7]]
    img.Image? rgbImage = _convertYUV420ToRGB(image);
    if (rgbImage == null) {
      throw Exception("Failed to convert YUV to RGB");
    }

    print("Resizing image to 640x640..."); // Debugging [[7]]
    // Resize to model's input size (640x640) [[2]]
    img.Image resizedImage = img.copyResize(rgbImage, width: 640, height: 640);

    print("Normalizing image pixels..."); // Debugging [[7]]
    // Convert to Float32List with normalization [[1]]
    Float32List input = Float32List(1 * 640 * 640 * 3); // Batch size 1
    for (int y = 0; y < 640; y++) {
      for (int x = 0; x < 640; x++) {
        int pixel = resizedImage.getPixel(x, y);
        input[(y * 640 + x) * 3 + 0] = ((pixel >> 16) & 0xFF) / 255.0; // Red
        input[(y * 640 + x) * 3 + 1] = ((pixel >> 8) & 0xFF) / 255.0;  // Green
        input[(y * 640 + x) * 3 + 2] = (pixel & 0xFF) / 255.0;         // Blue
      }
    }
    return input;
  }

  img.Image? _convertYUV420ToRGB(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final Plane yPlane = image.planes[0];
      final Plane uPlane = image.planes[1];
      final Plane vPlane = image.planes[2];

      img.Image rgbImage = img.Image(width, height); // Positional arguments [[7]]

      final int yStride = yPlane.bytesPerRow;
      final int uStride = uPlane.bytesPerRow;
      final int vStride = vPlane.bytesPerRow;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * yStride + x;
          if (yIndex >= yPlane.bytes.length) continue;

          final int uvX = x ~/ 2;
          final int uvY = y ~/ 2;
          final int uIndex = uvY * uStride + uvX;
          final int vIndex = uvY * vStride + uvX;

          if (uIndex >= uPlane.bytes.length || vIndex >= vPlane.bytes.length) continue;

          final int yValue = yPlane.bytes[yIndex];
          final int uValue = uPlane.bytes[uIndex];
          final int vValue = vPlane.bytes[vIndex];

          // Convert YUV to RGB [[1]]
          final int r = ((yValue + 1.402 * (vValue - 128)).clamp(0, 255)).toInt();
          final int g = ((yValue - 0.34414 * (uValue - 128) - 0.71414 * (vValue - 128)).clamp(0, 255).toInt());
          final int b = ((yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt());

          rgbImage.setPixelRgba(x, y, r, g, b); // Correct method [[7]]
        }
      }
      return rgbImage;
    } catch (e) {
      print("YUV conversion error: $e");
      return null;
    }
  }

  Map<String, dynamic> _runInference(Float32List input) {
    if (_interpreter == null) {
      throw Exception("Interpreter not initialized"); // Guard clause [[1]]
    }

    print("Running inference on input tensor..."); // Debugging [[7]]
    var output = <String, dynamic>{};
    try {
      _interpreter!.runForMultipleInputs([input], output.cast<int, Object>()); // Correct method name [[1]]
    } catch (e) {
      print("Interpreter error: $e");
    }
    return output;
  }

  List<dynamic> _postProcessOutput(dynamic rawOutput) {
    print("Post-processing inference output..."); // Debugging [[7]]
    List<dynamic> results = [];
    if (rawOutput == null || rawOutput.isEmpty) {
      print("Raw output is empty."); // Debugging [[7]]
      return results;
    }

    // Parse YOLO output (adjust based on your model's format) [[7]]
    var detections = rawOutput["output"] as List<List<double>>;
    for (var detection in detections) {
      double x = detection[0]; // Center x (0-1)
      double y = detection[1]; // Center y (0-1)
      double w = detection[2]; // Width (0-1)
      double h = detection[3]; // Height (0-1)
      double confidence = detection[4]; // Confidence score

      // Extract class probabilities
      List<double> classProbs = detection.sublist(5);
      int classIndex = classProbs.indexOf(classProbs.reduce((a, b) => a > b ? a : b));

      if (confidence > 0.1) {
        results.add({
          'label': "Class $classIndex", // Replace with labels from label.txt
          'confidence': confidence,
          'rect': {
            'x': x - w / 2, // Convert center to top-left
            'y': y - h / 2,
            'w': w,
            'h': h,
          },
        });
      }
    }

    // Add Non-Max Suppression (NMS) logic here [[7]]
    return results;
  }

  @override
  void dispose() {
    print("Disposing resources..."); // Debugging [[7]]
    _cameraController.dispose(); // Proper disposal of camera resources [[5]]
    _interpreter?.close(); // Close the interpreter to free resources [[1]]
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Object Detection")),
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController),
                DetectionOverlay(results: _results),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class DetectionOverlay extends StatelessWidget {
  final List<dynamic>? results;
  const DetectionOverlay({Key? key, this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return results == null || results!.isEmpty
        ? const Center(child: Text("No objects detected"))
        : CustomPaint(painter: DetectionPainter(results!));
  }
}

class DetectionPainter extends CustomPainter {
  final List<dynamic> results;
  DetectionPainter(this.results);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var result in results) {
      final rect = Rect.fromLTWH(
        result['rect']['x'] * size.width,
        result['rect']['y'] * size.height,
        result['rect']['w'] * size.width,
        result['rect']['h'] * size.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}