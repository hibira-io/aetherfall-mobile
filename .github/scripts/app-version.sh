#!/usr/bin/env bash
# Store version, server and build number from a release tag, mirroring
# hibira-io/hibira-app's app-version.sh and pixel-realm's tag scheme:
#
#   v1.2.3-dev.N  → server dev, version 1.2.3, build 1002003 * 100 + N       (N 1–49)
#   v1.2.3-rc.N   → server uat, version 1.2.3, build 1002003 * 100 + 50 + N  (N 1–48)
#   v1.2.3        → server prd, version 1.2.3, build 1002003 * 100 + 99
#
# Play's versionCode and the iOS build number must go up with every upload;
# this keeps dev < rc < release within a version and every 1.2.4 above 1.2.3.
set -euo pipefail
ref=${GITHUB_REF_NAME:-}
if [ "${GITHUB_REF_TYPE:-}" != tag ] || ! [[ "$ref" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)(-(dev|rc)\.([0-9]+))?$ ]]; then
  echo "::error::Run this from a release tag (v1.2.3-dev.1, v1.2.3-rc.1 or v1.2.3), not ${ref:-?}"
  exit 1
fi
major=${BASH_REMATCH[1]} minor=${BASH_REMATCH[2]} patch=${BASH_REMATCH[3]}
stage=${BASH_REMATCH[5]} n=${BASH_REMATCH[6]:-0}
if [ "$major" -gt 20 ] || [ "$minor" -gt 999 ] || [ "$patch" -gt 999 ]; then
  echo "::error::major must be at most 20, minor and patch below 1000"
  exit 1
fi
case "$stage" in
  dev) env=dev; [ "$n" -ge 1 ] && [ "$n" -le 49 ] || { echo "::error::dev.N must be 1–49"; exit 1; }; step=$((10#$n)) ;;
  rc) env=uat; [ "$n" -ge 1 ] && [ "$n" -le 48 ] || { echo "::error::rc.N must be 1–48"; exit 1; }; step=$((50 + 10#$n)) ;;
  *) env=prd; step=99 ;;
esac
{
  echo "name=${major}.${minor}.${patch}"
  echo "code=$(( (10#$major * 1000000 + 10#$minor * 1000 + 10#$patch) * 100 + step ))"
  echo "env=$env"
} | tee -a "${GITHUB_OUTPUT:-/dev/null}"
