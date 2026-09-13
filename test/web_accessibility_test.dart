import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web shell preserves zoom after Flutter injects its viewport', () {
    final html = File('web/index.html').readAsStringSync();

    expect(html, isNot(contains('user-scalable=no')));
    expect(html, isNot(contains('maximum-scale=1.0')));
    expect(html, contains('allowViewportZoom'));
    expect(html, contains('maximum-scale=5.0, user-scalable=yes'));
    expect(html, isNot(contains('Muslingo text input')));
  });
}
