// my_home_page.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../download.dart';

class HomePageUI extends StatefulWidget {
  const HomePageUI({super.key});

  @override
  _HomePageUIState createState() => _HomePageUIState();
}

class _HomePageUIState extends State<HomePageUI> {
  late TextEditingController _inputLinkController;
  late TextEditingController _outputPathController;

  @override
  void initState() {
    super.initState();
    _inputLinkController = TextEditingController();
    _outputPathController = TextEditingController();
  }

  Future<void> _handleDownload(BuildContext context) async {
    String link = _inputLinkController.text;
    String path = _outputPathController.text;

    try {
      await Downloader(musicLink: link, outputPath: path).downloadMusic();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Music downloaded successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NCM Downloader'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                      hintText: "输入音乐链接",
                      labelText: "Link",
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                FloatingActionButton.extended(
                  icon: Icon(Icons.download),
                  onPressed: () => _handleDownload(context),
                  // 调用逻辑处理下载
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
                      hintText: "保存到",
                      labelText: "Path",
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                FloatingActionButton.extended(
                  icon: Icon(Icons.save),
                  onPressed: () async {
                    // 调用逻辑处理保存路径
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
