#!/usr/bin/env bash
set -euo pipefail

pnpm test:api
./.vercel_flutter/bin/flutter test
./.vercel_flutter/bin/flutter build web --release \
  --dart-define="MUSLINGO_API_URL=${MUSLINGO_API_URL:-}" \
  --dart-define="MUSLINGO_SPEECH_API_URL=${MUSLINGO_SPEECH_API_URL:-}"
