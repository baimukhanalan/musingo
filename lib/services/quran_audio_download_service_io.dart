import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class QuranAudioDownloadService {
  final http.Client _client;

  QuranAudioDownloadService({http.Client? client})
      : _client = client ?? http.Client();

  Future<File> _fileFor(int chapterNumber) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDirectory = Directory('${directory.path}/quran_audio');
    if (!await audioDirectory.exists()) {
      await audioDirectory.create(recursive: true);
    }
    final padded = chapterNumber.toString().padLeft(3, '0');
    return File('${audioDirectory.path}/$padded.mp3');
  }

  Future<String?> localPathFor(int chapterNumber) async {
    final file = await _fileFor(chapterNumber);
    return await file.exists() && await file.length() > 0 ? file.path : null;
  }

  Future<int?> localSizeFor(int chapterNumber) async {
    final file = await _fileFor(chapterNumber);
    return await file.exists() ? file.length() : null;
  }

  Future<String> downloadChapterAudio({
    required int chapterNumber,
    required String url,
    void Function(int received, int? total)? onProgress,
  }) async {
    final file = await _fileFor(chapterNumber);
    final request = http.Request('GET', Uri.parse(url));
    final response = await _client.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Audio download failed: HTTP ${response.statusCode}');
    }

    final temp = File('${file.path}.part');
    final sink = temp.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.stream) {
        received += chunk.length;
        sink.add(chunk);
        onProgress?.call(received, response.contentLength);
      }
    } finally {
      await sink.close();
    }
    if (await file.exists()) await file.delete();
    await temp.rename(file.path);
    return file.path;
  }

  Future<void> deleteChapterAudio(int chapterNumber) async {
    final file = await _fileFor(chapterNumber);
    if (await file.exists()) await file.delete();
  }

  void dispose() => _client.close();
}
