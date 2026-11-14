# 星核崩落 Aetherfall — iPhone and Android app

The mobile app of [Aetherfall](https://github.com/hibira-io/pixel-realm), an original pixel-art MMORPG. It is a
[Capacitor](https://capacitorjs.com) 8 shell around the **same game client** the browser plays (Three.js + React
HUD, built from `hibira-io/pixel-realm`), talking to the same authoritative Go server. No second client, no
separate economy: one account, one world.

The build, signing and store flow copies [hibira-io/hibira-app](https://github.com/hibira-io/hibira-app) (the
Hibira app), with pixel-realm's dev/rc/release tags on top.

| | |
| --- | --- |
| App ID | `io.hibira.aetherfall` (iOS bundle ID and Android package), name 「星核崩落」 |
| Game client | Built from pixel-realm at the ref in `pixel-realm.ref` by `scripts/build-web.sh` and shipped **inside** the app (`www/`, not a remote URL), so it is a real app (App Store 4.2) and starts offline |
| Server | Chosen at build time: DEV `aetherfall-dev.hibira.io`, UAT `aetherfall-uat.hibira.io`, PRD `aetherfall.hibira.io` (`VITE_SERVER_ORIGIN` in the client). The server must list `capacitor://localhost` and `https://localhost` in `ALLOWED_ORIGINS` |
| User agent | ends in `AetherfallApp/ios` or `AetherfallApp/android` |
| Icons and splash | **Placeholders** (Capacitor's defaults) until Codex delivers the app icon and splash art |
| Sold in the app | Nothing yet. Any later purchase goes through Apple IAP / Google Play Billing, verified and granted once on the Go server |

Plan and open decisions: the mobile plan doc in the project (Capacitor chosen over React Native and native),
and pixel-realm's `docs/gameplay/product-mobile-strategy-v1.0.md` (Codex's design baseline, gates G1–G3).

## Working on it

```sh
npm ci
scripts/build-web.sh                         # clone pixel-realm (pixel-realm.ref), build the client for DEV into www/
AETHERFALL_ENV=https://<your-tunnel-host> \
  PIXEL_REALM_DIR=../pixel-realm scripts/build-web.sh   # your checkout, your own server behind an HTTPS tunnel
npx cap sync                                 # copy www/ and plugins into ios/ and android/
npx cap open android                         # Android Studio
npx cap open ios                             # Xcode, on a Mac
npm test                                     # IDs, version plumbing and tag mapping agree
```

Plain `http://` servers are refused: the app's pages load from `https://localhost` / `capacitor://localhost`, so
http calls are mixed content, and store builds keep cleartext off. The server also needs that origin in
`ALLOWED_ORIGINS`.

Bump `pixel-realm.ref` (a branch, tag or commit) in a pull request to ship a newer game client.

## Releasing

Push a tag (in this repo; pixel-realm has its own):

| Tag | Server | iPhone | Android |
| --- | --- | --- | --- |
| `v0.1.0-dev.N` | DEV | TestFlight | Play internal testing (draft) |
| `v0.1.0-rc.N` | UAT | TestFlight | Play closed testing (draft) |
| `v0.1.0` | PRD | TestFlight; the `PRD` environment's reviewer approves the run | Play production (draft) |

Build numbers come from the tag (`.github/scripts/app-version.sh`): `v1.2.3-dev.N` → `100200300 + N`,
`-rc.N` → `+ 50 + N`, the release → `+ 99`, so every upload goes up. Nothing is sent for App Store review or
rolled out on Play automatically; a person does that, and PRD needs Danny's approval.

Pull requests build both apps without signing (`ci.yml`) and keep a debug APK (DEV server) as the run's
artifact. **android-apk** (Run workflow) makes a signed APK for any server to install by hand.

## One-time setup

Most of it is shared with the Hibira app (same Apple team and org secrets):

1. **Apple.** Developer → Identifiers: App ID `io.hibira.aetherfall` (Push Notifications and Associated Domains
   come with M2). App Store Connect: new app with that bundle ID, named 「星核崩落」.
2. **Secrets.** Add this repo to the org secrets/variables the Hibira app uses: `APPLE_TEAM_ID` (variable),
   `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`. Android: `ANDROID_UPLOAD_KEYSTORE` (base64 of a new upload `.jks`
   for this app), `ANDROID_UPLOAD_PASSWORD`; optional `PLAY_SERVICE_ACCOUNT_JSON` to upload to Play. Make the key:
   `keytool -genkeypair -keystore upload.jks -alias upload -keyalg RSA -keysize 4096 -validity 10000 -dname "CN=Aetherfall, O=Hibira, C=TW"`,
   then `base64 -i upload.jks | gh secret set ANDROID_UPLOAD_KEYSTORE -R hibira-io/aetherfall-mobile`.
3. **Play Console.** Create the app `io.hibira.aetherfall`; the very first bundle is uploaded by hand.
4. **pixel-realm read access.** pixel-realm is private, and the hibira-io enterprise turns deploy keys off, so CI
   reads it through the org's GitHub App **Hibira CI** (org-owned, not tied to a person). Each job asks it for a
   one-hour token that can only read pixel-realm's contents. Setup: create the app under the organization
   (Repository permissions → Contents: Read-only, no webhook), install it on **pixel-realm only**, generate a
   private key, then add the org variable `HIBIRA_CI_APP_CLIENT_ID` (the app's Client ID) and org secret
   `HIBIRA_CI_APP_PRIVATE_KEY` (the `.pem`), both available to aetherfall-mobile. Other repos can reuse the app later:
   install it on more repos or add permissions as needed.
5. **Environments.** `DEV`, `UAT` and `PRD` are created on first use; give `PRD` a required reviewer.

## What comes next

- **M1** device check: touch controls, safe areas, landscape lock in combat, pause/disconnect on background and
  reconnect on resume, frame-rate report on a low-end Android, a mid-range Android and an older iPhone.
- **M2** native features, following the Hibira app: provider sign-in in the system browser coming back on the
  app's scheme with a one-time secret (Google refuses web views), Sign in with Apple (guideline 4.8), Hibira Push
  via `hibira-push-ios` / `hibira-push-android`, haptics, in-app account deletion.
- **M3** store listing (Codex makes the icon, splash and store art), privacy forms, age rating, review account.

Game-side changes (touch controls, lifecycle, quality tiers, sign-in) are made in pixel-realm so the browser
and the app stay one client. The app finds native plugins at `window.Capacitor.Plugins`; in a browser they are
absent and the client carries on.

## 中文摘要

星核崩落的 iPhone / Android App，用 Capacitor 包装与网页版**同一份**游戏客户端（从 pixel-realm 构建、打包进 App），连同一个 Go 服务器。
构建、签名、上架流程照 Hibira App（hibira-io/hibira-app）做；tag `v0.1.0-dev.N` 连 DEV 并送 TestFlight / Play 内测，`-rc.N` 连 UAT，
`v0.1.0` 连 PRD（需 Danny 批准，送审和上架由人手动按）。
