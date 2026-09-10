#!/usr/bin/env bash
set -euo pipefail

readonly flutter_revision="ee80f08bbf97172ec030b8751ceab557177a34a6"
readonly flutter_version="3.44.6"

pnpm install --frozen-lockfile

if [[ ! -d .vercel_flutter/.git ]]; then
  git init .vercel_flutter
  git -C .vercel_flutter remote add origin https://github.com/flutter/flutter.git
fi

git -C .vercel_flutter fetch --depth 1 origin "refs/tags/$flutter_version"
git -C .vercel_flutter checkout --detach FETCH_HEAD
test "$(git -C .vercel_flutter rev-parse HEAD)" = "$flutter_revision"

./.vercel_flutter/bin/flutter config --enable-web
./.vercel_flutter/bin/flutter pub get
