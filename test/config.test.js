// The app's ID, name and version plumbing live in several native files and
// workflows; these checks keep them in step (as in hibira-io/hibira-app).
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { execFileSync } from "node:child_process";

const read = (p) => readFileSync(new URL(`../${p}`, import.meta.url), "utf8");
const config = JSON.parse(read("capacitor.config.json"));
const APP_ID = "io.hibira.aetherfall";

test("one app ID everywhere", () => {
  assert.equal(config.appId, APP_ID);
  assert.match(read("ios/App/App.xcodeproj/project.pbxproj"), /PRODUCT_BUNDLE_IDENTIFIER = io\.hibira\.aetherfall;/);
  assert.match(read("android/app/build.gradle"), /applicationId "io\.hibira\.aetherfall"/);
  assert.match(read(".github/workflows/release.yml"), /packageName: io\.hibira\.aetherfall/);
});

test("the game ships inside the app, not as a remote site", () => {
  // Apple guideline 4.2: a game, not a wrapped website. The client is built
  // into www/ by scripts/build-web.sh and talks to the server by URL.
  assert.equal(config.webDir, "www");
  assert.equal(config.server?.url, undefined);
  assert.equal(config.ios.appendUserAgent, "AetherfallApp/ios");
  assert.equal(config.android.appendUserAgent, "AetherfallApp/android");
  // `ios.scheme` names the Xcode scheme for `cap run ios`; the project only has "App".
  assert.equal(config.ios.scheme, undefined);
  // Store builds stay HTTPS-only: no mixed content, no cleartext.
  assert.equal(config.android.allowMixedContent, false);
  assert.ok(!/usesCleartextTraffic="true"/.test(read("android/app/src/main/AndroidManifest.xml")));
});

test("Android takes the version from the release workflow", () => {
  const gradle = read("android/app/build.gradle");
  assert.match(gradle, /versionCode project\.findProperty\("versionCode"\)/);
  assert.match(gradle, /versionName project\.findProperty\("versionName"\)/);
  assert.match(read("android/app/src/main/AndroidManifest.xml"), /android:allowBackup="false"/);
});

test("game client is pinned to a pixel-realm ref", () => {
  assert.match(read("pixel-realm.ref").trim(), /^[\w./-]+$/);
});

const version = (tag) =>
  Object.fromEntries(
    execFileSync("bash", [".github/scripts/app-version.sh"], {
      cwd: new URL("..", import.meta.url),
      env: { ...process.env, GITHUB_REF_TYPE: "tag", GITHUB_REF_NAME: tag, GITHUB_OUTPUT: "/dev/null" },
      encoding: "utf8",
    })
      .trim()
      .split("\n")
      .map((l) => l.split("=")),
  );

test("release tags map to servers and rising build numbers", () => {
  assert.deepEqual(version("v0.1.0-dev.3"), { name: "0.1.0", code: "100003", env: "dev" });
  assert.deepEqual(version("v0.1.0-rc.1"), { name: "0.1.0", code: "100051", env: "uat" });
  assert.deepEqual(version("v0.1.0"), { name: "0.1.0", code: "100099", env: "prd" });
  const order = ["v0.1.0-dev.1", "v0.1.0-dev.49", "v0.1.0-rc.1", "v0.1.0", "v0.1.1-dev.1", "v1.0.0-dev.1"];
  const codes = order.map((t) => Number(version(t).code));
  assert.deepEqual([...codes].sort((a, b) => a - b), codes);
  assert.ok(Math.max(...codes) < 2_100_000_000, "Android versionCode limit");
  assert.throws(() => version("v1.0"));
  assert.throws(() => version("v1.0.0-dev.50"));
});
