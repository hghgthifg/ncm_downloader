import 'package:http/http.dart';
import 'dart:io';

class Downloader {
  final String musicLink;
  final String outputPath;
  bool _isDownloading = false;

  Downloader({required this.musicLink, required this.outputPath});
  Future<void> downloadMusic() async {
    if (_isDownloading) return;
    _isDownloading = true;

    // 下载
    RegExp regExp = RegExp(r'id=([^&]+)');
    final match = regExp.firstMatch(musicLink);
    String? idValue = match?.group(1);

    if (idValue == null || idValue.isEmpty) {
      throw ("Error: Invalid link.");
    }

    final downloadLink =
        "https://music.163.com/song/media/outer/url?id=$idValue";

    final response = await get(Uri.parse(downloadLink));
    try {
      if (response.statusCode == 200) {
        final directory = outputPath;
        final musicName = "music";
        final musicExtension = "mp3";
        if (directory == '') {
          throw ("Error: Invalid output path.");
        }
        final filePath = '$directory/$musicName.$musicExtension';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw ("Error: Failed to download music");
      }
    } catch (error) {
      _isDownloading = false;
      rethrow;
    } finally {
      _isDownloading = false;
    }
  }
}
