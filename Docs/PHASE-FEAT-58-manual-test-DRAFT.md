# Manual Test — FEAT-58 Portal Access Scanner ready (Portal draft)

**Canonical target:** `Fithub-documentation/manual-tests/PHASE-FEAT-58-manual-test.md`  
BizDev: copy/sync if docs PR lags this Portal branch.

See Verification Audit: `Docs/feat58-scanner-ready-verification-audit.md`.

## Prerequisites

- [ ] Portal branch `feature/portal-feat58-scanner-ready`
- [ ] Admin login + camera-capable browser

## Steps

| # | Step | Expected | Pass? |
|---|------|----------|-------|
| 1 | Home → Open scanner | G1 gate | |
| 2 | Allow camera | Overlay clears **without** QR | |
| 3 | Pending/deny | Enter code CTA in production | |
| 4 | Close scanner | Tracks stop; no “permission revoked” claim | |
| 5 | AR locale | RTL + permission note | |
| 6 | Valid QR | FEAT-01/12 path unchanged | |
