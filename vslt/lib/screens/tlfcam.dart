import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../main.dart';

import 'package:tflite/tflite.dart' as tfl;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String output = "";
  CameraImage? cameraImage;
  CameraController? cameraController;
  bool isWorking = false;
  /* late CameraController _controller;
  late CameraImage _savedImage;
  late tl.Interpreter _interpreter;
  late List<String> _labels;
  bool _isDetecting = false; */
  @override
  void initState() {
    super.initState();
    loadCamer();
  //  loadmodel();
  }

  @override
  void dispose() async {
    super.initState();
    await tfl.Tflite.close();

    cameraController?.dispose();
  }

  loadCamer() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      } 
        setState(() {
          cameraController!.startImageStream((imageStream) {
            if (!isWorking) {
              isWorking = true;
              cameraImage = imageStream;
            runModel();
            }
          });
        });
      
    });
  }

  /* runModel() async {
    if (cameraImage != null) {
      var predictions = await tfl.Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          //return the byte form of the plane
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );
      output = "";
      for (var element in predictions!) {
    setState(() {
    output = element['label'];
    print("out isss *********${output.toString()}");
  });
}

      
      /* predictions!.forEach((element) {
        setState(() {
          output = element['label'];
          print("out isss *********${output.toString()}");
        });
      }); */
    }
  } */

  bool isModelBusy = false;

  runModel() async {
    if (cameraImage != null && !isModelBusy) {
      isModelBusy = true;

      var predictions = await tfl.Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          //return the byte form of the plane
          return plane.bytes;
        }).toList(),
        
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 3,
        threshold: 0.1,
        asynch: true,
      );

      isModelBusy = false;
      predictions!.forEach((element) {
        setState(() {
          output = element['label'].toString();
          print("out isss *********${output.toString()}");
        });
      });
      /* if (predictions != null && predictions.isNotEmpty) {
      final newOutput = predictions[0]['label'];
      if (newOutput != output) {
        setState(() {
          output = newOutput;
        });
      }
    } */
    }
  }

  loadmodel() async {
    await tfl.Tflite.loadModel(
      model: "assets/mtest.tflite",
      labels: "assets/m.txt",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Camera"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width,
              child: !cameraController!.value.isInitialized
                  ? Container()
                  : AspectRatio(
                      aspectRatio: cameraController!.value.aspectRatio,
                      child: CameraPreview(cameraController!),
                    ),
            ),
          ),
          Text(
            output.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          )
        ],
      ),
    );
  }
}
 //********CHANGER I HAD MADE***** */
  /* 
  void _initializeModel() async {
    final modelData =
        await rootBundle.load('assets/keypoint_classifier.tflite');
    final labelsData = await rootBundle.loadString('assets/labels.txt');
    _interpreter = tl.Interpreter.fromBuffer(modelData.buffer.asUint8List());
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
      outputrec = label;
      print("outputt ${label.toString()}");
      // Replace this with your own code to display the label on the screen
    });

    _isDetecting = false;
  } */

/* extension TensorExtension on tl.Tensor {
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
} */
