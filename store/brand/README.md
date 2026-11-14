# Brand art used by the app

Final art by Codex, copied unchanged from hibira-io/pixel-realm
`art-source/codex/brand/` (provenance, prompts and QA: that folder's
`manifest.json`, `README.md` and `QA.md`):

- `app-1024.png` → iOS App Store icon (flattened onto #111629, no alpha)
- `app-maskable-512.png` → Android legacy and round launcher icons
- `emblem-dark-1024.png` → Android adaptive icon foreground (inside the 66dp
  safe circle, background #111629) and the iOS/Android splash screens

`python3 scripts/app-icons.py` regenerates every size from these files with
nearest-neighbor scaling. When Codex delivers new brand art, copy it here and
rerun the script.
