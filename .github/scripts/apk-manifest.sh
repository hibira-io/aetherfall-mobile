#!/usr/bin/env bash
# Names the signed test APK after its tag and writes android/latest.json for
# the landing page (pixel-realm game-server/internal/downloads reads it):
#
#   .github/scripts/apk-manifest.sh <app-release.apk> <out-dir>
#
# Env: TAG (v0.1.0-dev.1), NAME (0.1.0), CODE (versionCode), CHANNEL (dev|uat|prd),
# CERT_SHA256 (optional: signing certificate SHA-256, any case, colons allowed).
# Writes <out-dir>/aetherfall-<tag without v>.apk and <out-dir>/latest.json,
# and "file=android/aetherfall-….apk" to $GITHUB_OUTPUT.
set -euo pipefail
apk=$1 out=$2
: "${TAG:?}" "${NAME:?}" "${CODE:?}" "${CHANNEL:?}"
[[ "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-(dev|rc)\.[0-9]+)?$ ]] || { echo "::error::bad tag $TAG"; exit 1; }
case "$CHANNEL" in dev | uat | prd) ;; *) echo "::error::bad channel $CHANNEL"; exit 1 ;; esac
[ -s "$apk" ] || { echo "::error::no APK at $apk"; exit 1; }

mkdir -p "$out"
base="aetherfall-${TAG#v}.apk"
cp "$apk" "$out/$base"
size=$(wc -c < "$out/$base" | tr -d ' ')
sha=$(sha256sum "$out/$base" | cut -d' ' -f1)
min_sdk=$(sed -n 's/^[[:space:]]*minSdkVersion[[:space:]]*=[[:space:]]*\([0-9]*\).*/\1/p' android/variables.gradle 2>/dev/null | head -1)
min_sdk=${min_sdk:-0}
published=$(date -u +%Y-%m-%dT%H:%M:%SZ)
cert=$(printf '%s' "${CERT_SHA256:-}" | tr -d ':' | tr 'A-F' 'a-f')
[[ "$cert" =~ ^[0-9a-f]{64}$ ]] || cert=""

cat > "$out/latest.json" <<JSON
{"version":"$NAME","tag":"$TAG","build":$CODE,"channel":"$CHANNEL","file":"android/$base","size":$size,"sha256":"$sha","min_sdk":$min_sdk,"published_at":"$published","cert_sha256":"$cert"}
JSON
echo "file=android/$base" >> "${GITHUB_OUTPUT:-/dev/null}"
{
  echo "### Android test APK"
  echo "\`$base\` · $size bytes · SHA-256 \`$sha\`"
} >> "${GITHUB_STEP_SUMMARY:-/dev/null}"
cat "$out/latest.json"
