#!/usr/bin/env bash
# Builds the game client from hibira-io/pixel-realm into www/, which
# `npx cap sync` copies into both apps. The app ships the client inside it
# (no remote URL), so the store build is a real app and starts offline.
#
#   AETHERFALL_ENV   dev (default) | uat | prd | an https:// server origin, e.g. a
#                    tunnel to a server on your machine. Plain http:// does not
#                    work: the app's pages are https://localhost (Android) and
#                    capacitor://localhost (iOS), so http calls are blocked as
#                    mixed content and store builds allow no cleartext.
#   PIXEL_REALM_REF  branch, tag or commit; default: the line in pixel-realm.ref
#   PIXEL_REALM_DIR  use this checkout instead of cloning (local work)
set -euo pipefail
cd "$(dirname "$0")/.."

env_name=${AETHERFALL_ENV:-dev}
case "$env_name" in
  dev) origin=https://aetherfall-dev.hibira.io ;;
  uat) origin=https://aetherfall-uat.hibira.io ;;
  prd) origin=https://aetherfall.hibira.io ;;
  https://*) origin=${env_name%/} ;;
  http://*) echo "AETHERFALL_ENV must be https:// (the app blocks plain http as mixed content); use an HTTPS tunnel to a local server" >&2; exit 1 ;;
  *) echo "AETHERFALL_ENV must be dev, uat, prd or an https:// server origin, not '$env_name'" >&2; exit 1 ;;
esac

ref=${PIXEL_REALM_REF:-$(tr -d '[:space:]' < pixel-realm.ref)}
src=${PIXEL_REALM_DIR:-}
if [ -z "$src" ]; then
  src=.cache/pixel-realm
  rm -rf "$src"
  mkdir -p .cache
  git init -q "$src"
  git -C "$src" remote add origin https://github.com/hibira-io/pixel-realm.git
  git -C "$src" fetch -q --depth 1 origin "$ref"
  git -C "$src" checkout -q FETCH_HEAD
fi
commit=$(git -C "$src" rev-parse HEAD)

(
  cd "$src/game-client"
  npm ci --no-audit --no-fund
  VITE_SERVER_ORIGIN="$origin" npm run build
)

rm -rf www
cp -R "$src/game-client/dist" www
content_version=$(node -e 'try{process.stdout.write(String(require(process.argv[1]).content_version??""))}catch{}' "$(cd "$src" && pwd)/content/v1/manifest.json")
cat > www/build-info.json <<JSON
{"pixel_realm_ref":"$ref","pixel_realm_commit":"$commit","server":"$origin","content_version":"$content_version"}
JSON
echo "www/ built from pixel-realm $ref ($commit) for $origin"
