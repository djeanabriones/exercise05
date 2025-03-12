import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const CameraExample(),
    );
  }
}

class CameraExample extends StatefulWidget {
  const CameraExample({super.key});

  @override
  State<CameraExample> createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final image = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );

                setState(() {
                  imageFile = image == null ? null : File(image.path);
                });
              },
              child: const Text("Take Picture"),
            ),
            imageFile == null
                ? Container()
                : Padding(
                  padding: const EdgeInsets.all(30),
                  child: ClipRect(
                    child: Image.file(imageFile!, fit: BoxFit.cover),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
