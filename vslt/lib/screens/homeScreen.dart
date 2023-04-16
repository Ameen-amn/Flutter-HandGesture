/* import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vslt/main.dart';
import 'package:vslt/screens/tlfcam.dart';
import './tlfcam.dart';
List<CameraDescription>? cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(new MyApp());
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
 */