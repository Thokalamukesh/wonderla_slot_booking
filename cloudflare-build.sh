#!/usr/bin/env bash
set -euo pipefail

# Cloudflare Pages does not include the Flutter SDK in its build image.
# Download the stable SDK, then compile the app to the Pages output folder.
git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /tmp/flutter
export PATH="/tmp/flutter/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release
