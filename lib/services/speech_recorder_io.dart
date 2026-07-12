import 'dart:typed_data';

class SpeechRecorder {
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<void> start() async {
    _isRecording = true;
  }

  Future<Uint8List?> stop() async {
    _isRecording = false;
    return null;
  }

  Future<void> cancel() async {
    _isRecording = false;
  }
}
