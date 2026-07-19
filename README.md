# fithub_portal_admin

Pulse Gym Admin Portal (Flutter — Web / Desktop / Tablet).

## Web / compile-time parameters (required)

Supabase is injected only via `--dart-define` (see `lib/core/network/supabase_config.dart`).
**Web runs and `flutter build web` must set these parameters** or login shows “Supabase is not configured”.

1. Copy the example file and fill values from Supabase → Project Settings → API:

```bash
cp dart_defines.json.example dart_defines.json
```

```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_PUBLISHABLE_OR_ANON_KEY",
  "BASE_URL": "https://YOUR_PROJECT.supabase.co",
  "OCCUPANCY_BACKEND": "supabase"
}
```

| Define | Purpose |
|--------|---------|
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` | Auth + default Supabase occupancy adapter |
| `BASE_URL` | Dio `ApiProvider` host (portable HTTP adapter) |
| `OCCUPANCY_BACKEND` | `supabase` (default) or `http` — selects remote adapter |

`dart_defines.json` is gitignored — do not commit secrets.

2. Run or build with the defines file:

```bash
# Chrome (recommended helper)
./tool/run_web.sh run

# Production web build
./tool/run_web.sh build

# Or explicitly
flutter run -d chrome --dart-define-from-file=dart_defines.json
flutter build web --dart-define-from-file=dart_defines.json
```

In Cursor / VS Code: use launch config **Portal Admin (Chrome)** (`.vscode/launch.json`), which already passes `--dart-define-from-file=dart_defines.json`.
