#!/usr/bin/env bash
# Run / build Portal Admin for web with required Supabase dart-defines.
set -euo pipefail
cd "$(dirname "$0")/.."

DEFINES_FILE="${DART_DEFINES_FILE:-dart_defines.json}"

if [[ ! -f "$DEFINES_FILE" ]]; then
  echo "Missing $DEFINES_FILE"
  echo "Copy dart_defines.json.example → dart_defines.json and fill SUPABASE_URL + SUPABASE_ANON_KEY."
  exit 1
fi

MODE="${1:-run}"
shift || true

case "$MODE" in
  run)
    exec flutter run -d chrome \
      --dart-define-from-file="$DEFINES_FILE" \
      "$@"
    ;;
  build)
    exec flutter build web \
      --dart-define-from-file="$DEFINES_FILE" \
      "$@"
    ;;
  *)
    echo "Usage: $0 [run|build] [extra flutter args...]"
    exit 1
    ;;
esac
