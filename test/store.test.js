// App Store listing files (store/ios) stay within App Store Connect's limits,
// so the app-store workflow doesn't fail halfway through an upload.
import { test } from "node:test";
import assert from "node:assert/strict";
import { readdirSync, readFileSync } from "node:fs";

const dir = new URL("../store/ios/", import.meta.url);
const read = (p) => readFileSync(new URL(p, dir), "utf8");
const locales = readdirSync(new URL("metadata/", dir)).filter((f) => f.endsWith(".json") && f !== "app.json").map((f) => f.slice(0, -5));

test("listing texts fit App Store Connect's limits", () => {
  assert.ok(locales.includes("zh-Hant") && locales.includes("en-US"));
  for (const l of locales) {
    const t = JSON.parse(read(`metadata/${l}.json`));
    const len = (s) => [...(s ?? "")].length;
    assert.ok(len(t.name) >= 2 && len(t.name) <= 30, `${l} name`);
    assert.ok(len(t.subtitle) <= 30, `${l} subtitle`);
    assert.ok(len(t.keywords) <= 100, `${l} keywords`);
    assert.ok(len(t.promotionalText) <= 170, `${l} promotional text`);
    assert.ok(len(t.description) > 0 && len(t.description) <= 4000, `${l} description`);
    for (const k of ["privacyPolicyUrl", "supportUrl", "marketingUrl"]) assert.match(t[k], /^https:\/\/aetherfall\.hibira\.io\//, `${l} ${k}`);
  }
});

test("app-level listing data is complete", () => {
  const a = JSON.parse(read("metadata/app.json"));
  assert.equal(a.primaryCategory, "GAMES");
  assert.ok(a.primarySubcategoryOne?.startsWith("GAMES_"));
  assert.equal(a.contentRightsDeclaration, "DOES_NOT_USE_THIRD_PARTY_CONTENT");
  assert.ok(a.reviewNotes.length > 0 && a.reviewNotes.length <= 4000);
  // The app never points players at the cheaper web shop (store-iap-sync-v1.0 §1).
  for (const l of locales) assert.doesNotMatch(read(`metadata/${l}.json`), /creem|cheaper|便宜|官網購買/i);
});

test("every listing language has landscape screenshots", () => {
  for (const l of locales) {
    const files = readdirSync(new URL(`screenshots/${l}/`, dir)).filter((f) => /\.(jpe?g|png)$/i.test(f));
    assert.ok(files.length >= 1 && files.length <= 10, `${l}: ${files.length} screenshots`);
  }
});
