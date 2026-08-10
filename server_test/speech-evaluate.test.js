import assert from 'node:assert/strict';
import test from 'node:test';

import { normalizeSpeech, scoreSpeech } from '../server/routes/speech-evaluate.js';

test('speech scoring rejects one letter for a full ayah', () => {
  const spoken = normalizeSpeech('ب');
  const target = normalizeSpeech('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
  assert.ok(scoreSpeech(spoken, target) < 50);
});

test('speech scoring accepts a normalized full match', () => {
  const spoken = normalizeSpeech('بسم الله الرحمن الرحيم');
  const target = normalizeSpeech('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
  assert.equal(scoreSpeech(spoken, target), 100);
});

test('speech scoring tolerates a small recognition omission', () => {
  const spoken = normalizeSpeech('بسم الله الرحمن الرحيم');
  const target = normalizeSpeech('بسم الله الرحمن الرحيم');
  assert.ok(scoreSpeech(spoken.slice(0, -1), target) >= 80);
});
