import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class SpeechRecorder {
  web.MediaRecorder? _recorder;
  web.MediaStream? _stream;
  final List<web.Blob> _chunks = [];
  Completer<Uint8List?>? _stopCompleter;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<void> start() async {
    if (_isRecording) return;
    _chunks.clear();
    final constraints = web.MediaStreamConstraints(audio: true.toJS);
    final stream =
        await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
    _stream = stream;

    final mimeType = _bestMimeType();
    final options = mimeType == null
        ? web.MediaRecorderOptions()
        : web.MediaRecorderOptions(mimeType: mimeType);
    final recorder = web.MediaRecorder(stream, options);
    recorder.ondataavailable = ((web.Event event) {
      final blobEvent = event as web.BlobEvent;
      if (blobEvent.data.size > 0) _chunks.add(blobEvent.data);
    }).toJS;
    recorder.onstop = ((web.Event _) {
      unawaited(_finishStop());
    }).toJS;
    recorder.onerror = ((web.Event _) {
      _stopCompleter?.completeError(StateError('Не удалось записать голос.'));
      _cleanup();
    }).toJS;
    _recorder = recorder;
    _isRecording = true;
    recorder.start();
  }

  Future<Uint8List?> stop() async {
    final recorder = _recorder;
    if (!_isRecording || recorder == null) return null;
    _stopCompleter = Completer<Uint8List?>();
    recorder.stop();
    return _stopCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        _cleanup();
        return null;
      },
    );
  }

  Future<void> cancel() async {
    final recorder = _recorder;
    if (recorder != null && _isRecording) {
      try {
        recorder.stop();
      } catch (_) {}
    }
    _chunks.clear();
    _stopCompleter?.complete(null);
    _cleanup();
  }

  Future<void> _finishStop() async {
    try {
      if (_chunks.isEmpty) {
        _stopCompleter?.complete(null);
        return;
      }
      final blob = web.Blob(_chunks.toJS);
      final buffer = await blob.arrayBuffer().toDart;
      _stopCompleter?.complete(buffer.toDart.asUint8List());
    } catch (error) {
      _stopCompleter?.completeError(error);
    } finally {
      _cleanup();
    }
  }

  void _cleanup() {
    final stream = _stream;
    if (stream != null) {
      for (final track in stream.getTracks().toDart) {
        track.stop();
      }
    }
    _stream = null;
    _recorder = null;
    _isRecording = false;
  }

  String? _bestMimeType() {
    const candidates = [
      'audio/webm;codecs=opus',
      'audio/webm',
      'audio/mp4',
    ];
    for (final candidate in candidates) {
      if (web.MediaRecorder.isTypeSupported(candidate)) return candidate;
    }
    return null;
  }
}
