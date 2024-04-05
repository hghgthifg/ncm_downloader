import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NCM Downloader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NCM Downloader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _inputLinkController = TextEditingController();
  final TextEditingController _outputPathController = TextEditingController();
  bool _isDownloading = false;
  Future<void> _downloadMusic() async {
    setState(() {
      _isDownloading = true;
    });

    // 下载
    try {
      RegExp regExp = RegExp(r'id=([^&]+)');
      final match = regExp.firstMatch(_inputLinkController.text);
      String? idValue = match?.group(1);

      if (idValue == null || idValue.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Invalid link.')));
      }

      final downloadLink =
          "https://music.163.com/song/media/outer/url?id=" + idValue!;

      final response = await get(Uri.parse(downloadLink));
      if (response.statusCode == 200) {
        final directory = _outputPathController.text;
        final musicName = "music";
        final musicExtension = "mp3";
        final filePath = '$directory/$musicName.$musicExtension';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Music downloaded successfully.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download music.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputLinkController,
                    decoration: InputDecoration(
                      hintText: "Input music link.",
                      labelText: "Link",
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                FloatingActionButton.extended(
                  icon: Icon(Icons.download),
                  onPressed: _isDownloading ? null : _downloadMusic,
                  label: Text("下载"),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _outputPathController,
                    decoration: InputDecoration(
                      hintText: "Save to ...",
                      labelText: "Path",
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                FloatingActionButton.extended(
                  icon: Icon(Icons.save),
                  onPressed: () async {
                    var dir = await FilePicker.platform.getDirectoryPath();
                    if (dir != null) {
                      setState(() {
                        _outputPathController.text = dir;
                      });
                    }
                  },
                  label: Text("保存到"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
