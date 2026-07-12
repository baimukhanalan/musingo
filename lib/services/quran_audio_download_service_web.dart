class QuranAudioDownloadService {
  QuranAudioDownloadService();

  Future<String?> localPathFor(int chapterNumber) async => null;

  Future<int?> localSizeFor(int chapterNumber) async => null;

  Future<String> downloadChapterAudio({
    required int chapterNumber,
    required String url,
    void Function(int received, int? total)? onProgress,
  }) async {
    throw UnsupportedError(
      'Полное офлайн-аудио в web-версии требует браузерного Cache API. Сейчас доступно цельное потоковое аудио без пауз.',
    );
  }

  Future<void> deleteChapterAudio(int chapterNumber) async {}

  void dispose() {}
}
