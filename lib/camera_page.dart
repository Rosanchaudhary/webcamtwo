import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_experiment/video_page.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({this.cameras, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  late bool _isRecording = false;
  XFile? pictureFile;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.cameras![0],
      ResolutionPreset.max,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await controller.stopVideoRecording();
      Uint8List codeUnits = await file.readAsBytes();
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(filePath: file.path, codeUnits: codeUnits),
      );
      //ignore: use_build_context_synchronously
      Navigator.push(context, route);
    } else {
      await controller.prepareForVideoRecording();
      await controller.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SizedBox(
              height: 400,
              width: 400,
              child: CameraPreview(controller),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              _recordVideo();
              setState(() {});
            },
            child: Icon(_isRecording ? Icons.stop : Icons.circle),
          ),
        ),
        if (pictureFile != null)
          Image.network(
            pictureFile!.path,
            height: 200,
          )
        //Android/iOS
        // Image.file(File(pictureFile!.path)))
      ],
    );
  }
}
