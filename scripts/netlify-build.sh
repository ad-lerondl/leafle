#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  git clone --depth 1 --branch "${FLUTTER_CHANNEL:-stable}" \
    https://github.com/flutter/flutter.git "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
fi

flutter config --no-analytics
flutter pub get
flutter build web --release --base-href=/

mkdir -p build/web/privacy build/web/download
cp -R web-pages/privacy/. build/web/privacy/
cp -R web-pages/download/. build/web/download/
if [ -d web-pages/download/downloads ]; then
  mkdir -p build/web/downloads
  cp -R web-pages/download/downloads/. build/web/downloads/
fi

cat > build/web/_redirects <<'EOF'
/privacy /privacy/ 301
/download /download/ 301
/* /index.html 200
EOF