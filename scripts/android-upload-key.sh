#!/usr/bin/env bash
# Makes Aetherfall's own Android upload key and stores it as this repo's
# GitHub secrets, without the password ever being shown or typed:
#
#   ANDROID_UPLOAD_KEYSTORE   base64 of the .jks
#   ANDROID_UPLOAD_PASSWORD   random, used for the store and the key
#
# Run once on a trusted computer that has keytool (any JDK) and gh signed in
# as an admin of hibira-io/aetherfall-mobile:
#
#   scripts/android-upload-key.sh [backup-dir]     # default ~/Documents/aetherfall-android-key
#
# The backup dir gets upload.jks, password.txt (mode 600) and the
# certificate's SHA-256 (needed for Android App Links and Play). Keep it
# somewhere safe, such as a password manager; Play App Signing can reset a
# lost upload key, but that takes a support request. Refuses to overwrite
# an existing key or secret.
set -euo pipefail

REPO=${REPO:-hibira-io/aetherfall-mobile}
DIR=${1:-"$HOME/Documents/aetherfall-android-key"}
ALIAS=upload

command -v keytool >/dev/null || { echo "keytool not found: install a JDK (e.g. brew install --cask temurin)" >&2; exit 1; }
command -v gh >/dev/null || { echo "gh not found: brew install gh && gh auth login" >&2; exit 1; }
command -v openssl >/dev/null || { echo "openssl not found" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh is not signed in: gh auth login" >&2; exit 1; }

# Fails closed: if the list can't be read (no admin rights, network), stop.
secrets=$(gh secret list -R "$REPO") || { echo "Can't list $REPO secrets (need admin on the repo)." >&2; exit 1; }
if printf '%s\n' "$secrets" | awk '$1 == "ANDROID_UPLOAD_KEYSTORE" { found = 1 } END { exit !found }'; then
  echo "$REPO already has ANDROID_UPLOAD_KEYSTORE; not replacing it (delete it first if you really mean to)." >&2
  exit 1
fi
if [ -e "$DIR/upload.jks" ]; then
  echo "$DIR/upload.jks already exists; not overwriting it." >&2
  exit 1
fi

umask 077
mkdir -p "$DIR"
PASS=$(openssl rand -base64 33 | tr -d '/+=\n' | cut -c1-32)
printf '%s' "$PASS" > "$DIR/password.txt"

# The password goes through an environment variable, never the command line.
export AF_KEY_PASS="$PASS"
keytool -genkeypair -keystore "$DIR/upload.jks" -storetype PKCS12 -alias "$ALIAS" \
  -keyalg RSA -keysize 4096 -validity 10000 \
  -dname "CN=Aetherfall, O=Hibira, C=TW" \
  -storepass:env AF_KEY_PASS -keypass:env AF_KEY_PASS >/dev/null

keytool -list -v -keystore "$DIR/upload.jks" -alias "$ALIAS" -storepass:env AF_KEY_PASS \
  | sed -n 's/^[[:space:]]*SHA256: //p' > "$DIR/sha256.txt"
unset AF_KEY_PASS

base64 < "$DIR/upload.jks" | tr -d '\n' | gh secret set ANDROID_UPLOAD_KEYSTORE -R "$REPO"
gh secret set ANDROID_UPLOAD_PASSWORD -R "$REPO" < "$DIR/password.txt"

echo "Done. $REPO now has ANDROID_UPLOAD_KEYSTORE and ANDROID_UPLOAD_PASSWORD."
echo "Backup: $DIR (upload.jks, password.txt). Move it to a password manager or another safe place."
echo "Note: if ~/Documents syncs to iCloud, the backup is uploaded there too; move it out if you don't want that."
echo "Upload certificate SHA-256: $(cat "$DIR/sha256.txt")"
