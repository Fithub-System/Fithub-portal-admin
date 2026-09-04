#!/usr/bin/env bash
# Run / build Portal Admin on iOS, Android, macOS, or Windows
# with required Supabase dart-defines.
set -euo pipefail
cd "$(dirname "$0")/.."

DEFINES_FILE="${DART_DEFINES_FILE:-dart_defines.json}"

if [[ ! -f "$DEFINES_FILE" ]]; then
  echo "Missing $DEFINES_FILE"
  echo "Copy dart_defines.json.example → dart_defines.json and fill SUPABASE_URL + SUPABASE_ANON_KEY."
  exit 1
fi

PLATFORM="${1:-}"
MODE="${2:-run}"
shift 2 2>/dev/null || true

usage() {
  echo "Usage: $0 <ios|android|macos|windows> [run|build] [extra flutter args...]"
  echo
  echo "Examples:"
  echo "  $0 ios"
  echo "  $0 android run"
  echo "  $0 macos build --release"
  echo "  DEVICE_ID=<simulator-udid> $0 ios run"
  echo "  $0 ios run -d \"iPad Pro\""
  exit 1
}

case "$PLATFORM" in
  ios|android|macos|windows) ;;
  *)
    usage
    ;;
esac

# flutter -d matches device id/name prefixes, not platform labels.
# "-d ios" fails when simulators are listed (see flutter devices).
has_device_flag=false
for arg in "$@"; do
  case "$arg" in
    -d|--device-id) has_device_flag=true ;;
  esac
done

resolve_device() {
  if [[ -n "${DEVICE_ID:-}" ]]; then
    echo "$DEVICE_ID"
    return
  fi
  case "$1" in
    macos) echo "macos" ;;
    windows) echo "windows" ;;
    ios)
      # Prefer a booted iPhone simulator name prefix; falls back to any iPhone.
      local booted
      booted="$(
        xcrun simctl list devices available 2>/dev/null \
          | grep -E 'iPhone.+\(Booted\)' \
          | head -n 1 \
          | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/' \
          || true
      )"
      if [[ -n "$booted" ]]; then
        echo "$booted"
      else
        echo "iPhone"
      fi
      ;;
    android)
      echo "android"
      ;;
  esac
}

case "$MODE" in
  run)
    if [[ "$has_device_flag" == true ]]; then
      exec flutter run \
        --dart-define-from-file="$DEFINES_FILE" \
        "$@"
    else
      DEVICE="$(resolve_device "$PLATFORM")"
      echo "Using device: $DEVICE"
      exec flutter run -d "$DEVICE" \
        --dart-define-from-file="$DEFINES_FILE" \
        "$@"
    fi
    ;;
  build)
    exec flutter build "$PLATFORM" \
      --dart-define-from-file="$DEFINES_FILE" \
      "$@"
    ;;
  *)
    usage
    ;;
esac
