# Vercel test preview — Option 3 (GitHub Actions)

**Policy:** Deploy Portal Flutter **web** only when `dev` is updated.  
**Tracking:** [portal#7](https://github.com/Fithub-System/Fithub-portal-admin/issues/7) · Backend Auth cutover [backend#7](https://github.com/Fithub-System/Fithub-backend/issues/7)

Workflow: `.github/workflows/deploy-vercel-dev.yml`

## One-time: Vercel project

1. Create / open project **fithub-portal-admin** (Application Preset: **Other**).
2. **Settings → Git**
   - Production Branch = **`dev`**
   - Turn **off** automatic deployments from Git (or set Ignored Build Step to `exit 0`) so **only** GitHub Actions deploys. Avoids a broken Flutter-less build on Vercel.
3. Copy IDs from **Settings → General**:
   - Project ID → `VERCEL_PROJECT_ID`
   - Team / Org ID → `VERCEL_ORG_ID`
4. Create a token: Vercel → Account Settings → Tokens → `VERCEL_TOKEN`

## One-time: GitHub secrets

Repo → **Settings → Secrets and variables → Actions** → add:

| Secret | Required | Notes |
|--------|----------|--------|
| `VERCEL_TOKEN` | yes | Deploy token |
| `VERCEL_ORG_ID` | yes | Team/org id |
| `VERCEL_PROJECT_ID` | yes | Project id |
| `SUPABASE_URL` | yes | e.g. `https://fykrrubvlkoqcgntgprc.supabase.co` |
| `SUPABASE_ANON_KEY` | yes | Publishable/anon key — **not** service role |
| `AUTH_REDIRECT_URL` | after first URL | e.g. `https://fithub-portal-admin.vercel.app/` |

`BASE_URL` / `OCCUPANCY_BACKEND` are set in the workflow from `SUPABASE_URL`.

## Deploy

1. Merge this feature branch → **`dev`** (or push to `dev`).
2. Actions tab → **Deploy Vercel (dev)** must be green.
3. Vercel → Project → **Domains / Deployments** → copy the **Production** HTTPS URL.
4. Set GitHub secret `AUTH_REDIRECT_URL` to that origin (trailing `/` OK).
5. Re-run workflow (**workflow_dispatch** or empty commit on `dev`) so the web build embeds the redirect URL.
6. Hand the same URL to Backend for Supabase Site URL + Edge `AUTH_REDIRECT_URL` (`docs/kickoff-vercel-dev-preview.md` in `Fithub-backend`).

## Local parity

```bash
cp dart_defines.json.example dart_defines.json
# fill SUPABASE_* (+ AUTH_REDIRECT_URL when known)
./tool/run_web.sh build
```

## Do not

- Use rotating per-PR Vercel preview URLs as Supabase Site URL
- Commit `dart_defines.json` or service-role keys
- Leave Vercel Git auto-build enabled without Flutter (it will fail / fight Actions)
