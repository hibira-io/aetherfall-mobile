// Sign in with Apple (App Store guideline 4.8): the native plugin, the
// entitlement and the capability must stay wired together.
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const read = (p) => readFileSync(new URL(`../${p}`, import.meta.url), "utf8");

test("Sign in with Apple is wired into the iPhone app", () => {
  assert.match(read("ios/App/App/App.entitlements"), /<key>com\.apple\.developer\.applesignin<\/key>\s*<array>\s*<string>Default<\/string>/);
  const pbx = read("ios/App/App.xcodeproj/project.pbxproj");
  assert.equal(pbx.match(/CODE_SIGN_ENTITLEMENTS = App\/App\.entitlements;/g)?.length, 2, "Debug and Release sign with the entitlement");
  assert.equal(JSON.parse(read("package.json")).dependencies["aetherfall-apple-sign-in"], "file:plugins/aetherfall-apple-sign-in");
  assert.match(read("ios/App/CapApp-SPM/Package.swift"), /\.product\(name: "AetherfallAppleSignIn", package: "AetherfallAppleSignIn"\)/);
  // The game client looks the plugin up by this name (pixel-realm net/appleSignIn.ts).
  const swift = read("plugins/aetherfall-apple-sign-in/ios/Sources/AetherfallAppleSignInPlugin/AetherfallAppleSignInPlugin.swift");
  assert.match(swift, /jsName = "AetherfallAppleSignIn"/);
  assert.match(swift, /CAPPluginMethod\(name: "authorize"/);
});
