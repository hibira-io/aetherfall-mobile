#!/usr/bin/env python3
"""Regenerate the app icons and splash screens from store/brand/ (Codex's
final brand art, copied from pixel-realm art-source/codex/brand/).

    python3 scripts/app-icons.py      # needs Pillow

Pixel art: every resize is nearest-neighbor, never interpolated.
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
BRAND = ROOT / "store/brand"
RES = ROOT / "android/app/src/main/res"
XC = ROOT / "ios/App/App/Assets.xcassets"
BG = (17, 22, 41)  # the icons' flat background, #111629
NN = Image.Resampling.NEAREST


def opaque(im):
    out = Image.new("RGB", im.size, BG)
    out.paste(im, mask=im.getchannel("A"))
    return out


app = Image.open(BRAND / "app-1024.png").convert("RGBA")
maskable = Image.open(BRAND / "app-maskable-512.png").convert("RGBA")
emblem = Image.open(BRAND / "emblem-dark-1024.png").convert("RGBA")
emblem = emblem.crop(emblem.getchannel("A").getbbox())

# iOS: one 1024 icon, opaque (App Store rejects alpha).
opaque(app).save(XC / "AppIcon.appiconset/AppIcon-512@2x.png")

# Android legacy and round icons (48dp), and the adaptive foreground (108dp)
# with the emblem inside the 66dp safe circle on a transparent canvas.
for d, s in {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}.items():
    px = round(48 * s)
    icon = opaque(maskable.resize((px, px), NN))
    icon.save(RES / f"mipmap-{d}/ic_launcher.png")
    round_mask = Image.new("L", (px * 4, px * 4), 0)
    ImageDraw.Draw(round_mask).ellipse((0, 0, px * 4 - 1, px * 4 - 1), fill=255)
    r = icon.convert("RGBA")
    r.putalpha(round_mask.resize((px, px), Image.Resampling.LANCZOS))
    r.save(RES / f"mipmap-{d}/ic_launcher_round.png")
    fg_px = round(108 * s)
    side = round(fg_px * 60 / 108)  # longest emblem side inside the 66dp circle
    k = side / max(emblem.size)
    e = emblem.resize((max(1, round(emblem.width * k)), max(1, round(emblem.height * k))), NN)
    fg = Image.new("RGBA", (fg_px, fg_px), (0, 0, 0, 0))
    fg.paste(e, ((fg_px - e.width) // 2, (fg_px - e.height) // 2), e)
    fg.save(RES / f"mipmap-{d}/ic_launcher_foreground.png")
(RES / "values/ic_launcher_background.xml").write_text(
    '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">#111629</color>\n</resources>\n'
)


def splash(w, h):
    out = Image.new("RGB", (w, h), BG)
    side = max(1, round(min(w, h) * 0.28))
    k = side / max(emblem.size)
    e = emblem.resize((max(1, round(emblem.width * k)), max(1, round(emblem.height * k))), NN)
    out.paste(e, ((w - e.width) // 2, (h - e.height) // 2), e)
    return out


for p in sorted(RES.glob("drawable*/splash.png")):
    w, h = Image.open(p).size
    splash(w, h).save(p)
for p in sorted((XC / "Splash.imageset").glob("*.png")):
    w, h = Image.open(p).size
    splash(w, h).save(p)
print("icons and splash screens written")
