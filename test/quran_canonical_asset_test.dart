import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled Tanzil text contains every surah and ayah in order', () async {
    const expectedCounts = <int>[
      7,
      286,
      200,
      176,
      120,
      165,
      206,
      75,
      129,
      109,
      123,
      111,
      43,
      52,
      99,
      128,
      111,
      110,
      98,
      135,
      112,
      78,
      118,
      64,
      77,
      227,
      93,
      88,
      69,
      60,
      34,
      30,
      73,
      54,
      45,
      83,
      182,
      88,
      75,
      85,
      54,
      53,
      89,
      59,
      37,
      35,
      38,
      29,
      18,
      45,
      60,
      49,
      62,
      55,
      78,
      96,
      29,
      22,
      24,
      13,
      14,
      11,
      11,
      18,
      12,
      12,
      30,
      52,
      52,
      44,
      28,
      28,
      20,
      56,
      40,
      31,
      50,
      40,
      46,
      42,
      29,
      19,
      36,
      25,
      22,
      17,
      19,
      26,
      30,
      20,
      15,
      21,
      11,
      8,
      8,
      19,
      5,
      8,
      8,
      11,
      11,
      8,
      3,
      9,
      5,
      4,
      7,
      3,
      6,
      3,
      5,
      4,
      5,
      6,
    ];
    final content = await rootBundle.loadString(
      'assets/data/quran-uthmani-tanzil.txt',
    );
    final counts = List<int>.filled(114, 0);
    var total = 0;

    for (final line in const LineSplitter().convert(content)) {
      if (!RegExp(r'^\d+\|\d+\|').hasMatch(line)) continue;
      final parts = line.split('|');
      final surah = int.parse(parts[0]);
      final ayah = int.parse(parts[1]);
      final text = parts.sublist(2).join('|');
      expect(surah, inInclusiveRange(1, 114));
      expect(ayah, counts[surah - 1] + 1);
      expect(text.trim(), isNotEmpty);
      counts[surah - 1]++;
      total++;
    }

    expect(counts, expectedCounts);
    expect(total, 6236);
  });
}
