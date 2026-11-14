# CLAUDE.md — 星核崩落 Aetherfall mobile app

The iPhone and Android app of Aetherfall. Read `README.md` first. The game itself, its rules and its design
docs live in [hibira-io/pixel-realm](https://github.com/hibira-io/pixel-realm); its `CLAUDE.md` applies here
too (server-authoritative gameplay, numbers in content files, idempotent rewards, original assets only, never
claim a test or build passed unless you ran it).

## What lives where

| Here (aetherfall-mobile) | In pixel-realm |
| --- | --- |
| Capacitor shell: `capacitor.config.json`, `ios/`, `android/`, native plugins | Game client (`game-client/`): rendering, HUD, touch controls, lifecycle handling, quality tiers |
| Store build and release: `.github/workflows/`, `.github/scripts/`, store metadata | Go server: auth (app sign-in return), push sending, purchase verification, `ALLOWED_ORIGINS`, `.well-known` files |
| `scripts/build-web.sh`, `pixel-realm.ref` (which client the app ships) | GDD and design (Codex), all art sources (Codex) |

Don't fork game code into this repo. If the app needs a client change, make it in pixel-realm behind a
platform check (`window.Capacitor`), then bump `pixel-realm.ref`.

## Ownership

Same split as pixel-realm: **Codex** owns design docs and all final art (app icon, splash, touch-control art,
store graphics and screenshots frames); Claude builds the shell, CI and integration. Ask Codex through a GitHub
issue or an `@codex` comment. Placeholders must be marked as placeholders. `AGENTS.md` holds Codex's copy of
these rules; keep the two in step.

## Conventions

- Mirror hibira-io/hibira-app (same org, same Capacitor 8 setup, same signing and store scripts) unless the
  game needs something else; say why in the PR when it does.
- Releases are tags: `vX.Y.Z-dev.N` → DEV, `-rc.N` → UAT, `vX.Y.Z` → PRD. Never push a PRD tag, submit for App
  Store review or roll out on Play without Danny's approval.
- Work on a branch, open a draft PR to `main`; the project's merge thread merges.
- Secrets only in GitHub secrets (org-level shared with hibira-app). Never commit keystores, `.p8` keys,
  `google-services.json` or `.env`.

## Checks (what CI runs)

```sh
npm ci && npm test
shellcheck -S warning scripts/*.sh .github/scripts/*.sh
scripts/build-web.sh && npx cap sync
cd android && ./gradlew assembleDebug            # needs the Android SDK (platform 36, build-tools 36.0.0)
# iOS: xcodebuild … -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build (Mac only; CI uses macos-26)
```
