import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/lesson_video.dart';
import '../services/app_state.dart';
import '../services/lesson_video_catalog.dart';
import '../services/lesson_video_segments.dart';
import '../services/video_embed_platform_stub.dart'
    if (dart.library.js_interop) '../services/video_embed_platform_web.dart';
import '../utils/colors.dart';

/// Hosts the provider's official embedded player inside Muslingo. No video
/// stream is downloaded, proxied or repackaged by the application.
class LessonVideoPlayerScreen extends StatefulWidget {
  final LessonVideo video;
  final LessonVideoSegment? segment;
  final Widget Function(Uri)? playerBuilder;

  const LessonVideoPlayerScreen({
    super.key,
    required this.video,
    this.segment,
    this.playerBuilder,
  });

  @override
  State<LessonVideoPlayerScreen> createState() =>
      _LessonVideoPlayerScreenState();
}

class _LessonVideoPlayerScreenState extends State<LessonVideoPlayerScreen> {
  WebViewController? _controller;
  String? _error;

  Uri get _playbackUri =>
      widget.segment?.playbackUri(widget.video) ??
      Uri.parse(widget.video.embedUrl);

  @override
  void initState() {
    super.initState();
    if (!const LessonVideoPolicy().validate(widget.video).canDisplay) {
      _error = 'invalid_video';
      return;
    }
    try {
      _playbackUri;
    } catch (_) {
      _error = 'invalid_segment';
      return;
    }
    if (widget.playerBuilder == null) _load();
  }

  Future<void> _load() async {
    try {
      registerVideoEmbedPlatform();
      final controller = WebViewController();
      if (!kIsWeb) {
        await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
        await controller.setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (request) =>
              isAllowedEmbeddedVideoNavigation(Uri.tryParse(request.url))
                  ? NavigationDecision.navigate
                  : NavigationDecision.prevent,
        ));
      }
      await controller.loadRequest(
        _playbackUri,
        // YouTube requires an identifiable embedding client in native
        // WebViews. A browser iframe supplies the page origin automatically.
        headers: kIsWeb
            ? const {}
            : const {'Referer': 'https://muslingo-mobile.vercel.app/'},
      );
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (error) {
      debugPrint('Embedded lesson video failed: $error');
      if (!mounted) return;
      setState(() => _error = 'player_unavailable');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final title = state.tr(
      ru: 'Видеоурок',
      kk: 'Бейнесабақ',
      en: 'Video lesson',
    );
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.navyDark,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                // YouTube requires an embedded player viewport at least 200 px
                // high. Narrow phones would fall below that at a strict 16:9.
                height: (constraints.maxWidth * 9 / 16).clamp(200.0, 420.0),
                child: widget.playerBuilder != null
                    ? widget.playerBuilder!(_playbackUri)
                    : _controller != null
                        ? WebViewWidget(
                            key: const ValueKey('lesson-video-embedded-player'),
                            controller: _controller!,
                          )
                        : Center(
                            child: _error == null
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    state.tr(
                                      ru: 'Встроенный плеер недоступен. Вернись к конспекту урока.',
                                      kk: 'Кірістірілген ойнатқыш қолжетімсіз. Сабақ конспектісіне орал.',
                                      en: 'The embedded player is unavailable. Return to the lesson notes.',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                          ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                widget.video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 21,
                ),
              ),
            ),
            if (widget.segment != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${widget.segment!.number}/${widget.segment!.total} · '
                  '${lessonVideoTimecode(widget.segment!.startSeconds)}–'
                  '${lessonVideoTimecode(widget.segment!.endSeconds)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.video.source.publisher,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: OutlinedButton.icon(
                key: const ValueKey('lesson-video-close'),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(state.tr(
                  ru: 'Вернуться к уроку',
                  kk: 'Сабаққа оралу',
                  en: 'Back to lesson',
                )),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@visibleForTesting
bool isAllowedEmbeddedVideoNavigation(Uri? uri) {
  if (uri == null || uri.scheme != 'https') return false;
  final host = uri.host.toLowerCase();
  if (host == 'www.youtube-nocookie.com' || host == 'youtube-nocookie.com') {
    return uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'embed';
  }
  if (host == 'player.vimeo.com') {
    return uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'video';
  }
  return false;
}
