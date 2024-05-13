import 'dart:typed_data';

import 'package:audiotags/audiotags.dart';
import 'package:http/http.dart';
import 'dart:convert';
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

    if (outputPath == '' || Directory(outputPath).existsSync() == false) {
      throw ("Error: Invalid output path.");
    }

    try {
      _downloadMusic(idValue, outputPath);
    } catch (error) {
      _isDownloading = false;
      rethrow;
    } finally {
      _isDownloading = false;
    }
  }

  Future<void> _downloadMusic(String id, String outputPath) async {
    final downloadLink = "https://music.163.com/song/media/outer/url?id=$id";
    final String detailLink =
        "https://music.163.com/api/song/detail/?id=$id&ids=[$id]";

    final detailResponse = await get(Uri.parse(detailLink));
    if (detailResponse.statusCode == 200) {
      final info = jsonDecode(detailResponse.body)['songs'][0];

      // Get the metadata
      final title = info['name'];
      final artists =
          info['artists'].map((artist) => artist['name']).toList().toString();
      final album = info['album']['name'];
      final albumArtists = info['album']['artists']
          .map((artist) => artist['name'])
          .toList()
          .toString();
      final trackTotal = info['album']['size'];
      final trackNumber = info['no'];

      // Get the cover
      final coverUrl = info['album']['picUrl'];
      final coverResponse = await get(
        Uri.parse(coverUrl),
        headers: {
          HttpHeaders.userAgentHeader:
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36",
        },
      );
      final coverBytes = coverResponse.bodyBytes;

      final Tag tag = Tag(
          title: title,
          trackArtist: artists,
          album: album,
          albumArtist: albumArtists,
          genre: null,
          year: null,
          trackNumber: trackNumber,
          trackTotal: trackTotal,
          discNumber: null,
          discTotal: null,
          pictures: [
            Picture(
                pictureType: PictureType.coverFront,
                bytes: coverBytes,
                mimeType: MimeType.jpeg),
            Picture(
                pictureType: PictureType.coverBack,
                bytes: coverBytes,
                mimeType: MimeType.jpeg),
            Picture(
                pictureType: PictureType.icon,
                bytes: coverBytes,
                mimeType: MimeType.jpeg),
          ]);

      final fileResponse = await get(Uri.parse(downloadLink));
      if (fileResponse.statusCode != 200) {
        throw ("Error: Failed to download music file. (code : ${fileResponse.statusCode})");
      }

      final musicName = title;
      final musicExtension = "mp3";
      final filePath = '$outputPath/$musicName.$musicExtension';
      final file = File(filePath);
      await file.writeAsBytes(fileResponse.bodyBytes);
      AudioTags.write(filePath, tag);
    } else {
      throw ("Error: Failed to download music details");
    }
  }
}
