import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/lesson_video_player_screen.dart';

void main() {
  test('native player keeps navigation on approved provider embeds', () {
    expect(
        isAllowedEmbeddedVideoNavigation(Uri.parse(
            'https://www.youtube-nocookie.com/embed/o4oRsk4BIMU?start=60')),
        isTrue);
    expect(
        isAllowedEmbeddedVideoNavigation(
            Uri.parse('https://player.vimeo.com/video/123456')),
        isTrue);
    expect(
        isAllowedEmbeddedVideoNavigation(
            Uri.parse('https://www.youtube.com/watch?v=o4oRsk4BIMU')),
        isFalse);
    expect(
        isAllowedEmbeddedVideoNavigation(
            Uri.parse('youtube://watch?v=o4oRsk4BIMU')),
        isFalse);
    expect(isAllowedEmbeddedVideoNavigation(Uri.parse('https://evil.test/')),
        isFalse);
  });
}
