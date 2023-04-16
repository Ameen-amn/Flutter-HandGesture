/* import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Language Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraPreviewWidget(),
    );
  }
}

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({Key? key}) : super(key: key);

  @override
  _CameraPreviewWidgetState createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  late CameraController _controller;
  late CameraImage _savedImage;
  late tfl.Interpreter _interpreter;
  late List<String> _labels;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
    _initializeCamera().then((_) {
      setState(() {});
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.high);
    await _controller.initialize();
    _controller.startImageStream((image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _savedImage = image;
        _runModelOnFrame();
      }
    });
  }

  void _initializeModel() async {
    final modelData =
        await rootBundle.load('assets/keypoint_classifier.tflite');
    final labelsData = await rootBundle.loadString('assets/labels.txt');
    _interpreter = tfl.Interpreter.fromBuffer(modelData.buffer.asUint8List());
    _labels = labelsData.split('\n');
  }

  void _runModelOnFrame() async {
  // Convert the camera image to a format that the model can use
  final input = _savedImage.planes.map((plane) {
    return Float32List.fromList(plane.bytes.toList().cast<double>());
  }).toList();
  final shape = _savedImage.planes[0].height! * _savedImage.planes[0].width!;
  final convertedInput = [input[0].buffer.asFloat32List(shape)];

  // Run the model
  _interpreter.run(convertedInput, {});

  final output = _interpreter.getOutputTensor(0);

  // Process the model output to get the recognized sign
  final prediction = output.getFloatValue(0);
  final labelIndex = prediction.round();
  final label = _labels[labelIndex];

  // Display the recognized sign on the screen
  setState(() {
    print("Recognized Sign: ${label.toString()}");
    // Replace this with your own code to display the label on the screen
  });

  _isDetecting = false;
}

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: CameraPreview(_controller),
    );
  }
}

extension TensorExtension on tfl.Tensor {
  List<double> getDataAsFloat32List() {
    return this.data.buffer.asFloat32List();
  }

  List<int> getDataAsInt32List() {
    return this.data.buffer.asInt32List();
  }

  double getFloatValue(int index) {
    final data = this.getDataAsFloat32List();
    return data[index];
  }

  int getIntValue(int index) {
    final data = this.getDataAsInt32List();
    return data[index];
  }
}
 */

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vslt/main.dart';
import 'package:vslt/screens/tlfcam.dart';

List<CameraDescription>? cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
