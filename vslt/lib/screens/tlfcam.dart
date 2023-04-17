import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'package:tflite/tflite.dart' as tfl;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String output = "";
  CameraImage? cameraImage;
  CameraController? cameraController;
  bool isWorking = false;

  @override
  void initState() {
    super.initState();
    loadCamer();
    loadmodel();
  }

  @override
  void dispose() async {
    super.dispose();
    await tfl.Tflite.close();

    cameraController?.dispose();
  }

  loadCamer() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    
    cameraController!.initialize().then((_) {
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
        });
      });
    }
  }

  loadmodel() async {
    await tfl.Tflite.loadModel(
      model: "assets/keypoint_classifier.tflite",
      labels: "assets/labels.txt",
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
