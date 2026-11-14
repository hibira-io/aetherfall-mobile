# AGENTS.md — 星核崩落 Aetherfall mobile app

Instructions for **Codex** (and any other non-Claude agent). Claude Code reads `CLAUDE.md`; both describe the
same rules. The game, its GDD and your full rules live in
[hibira-io/pixel-realm](https://github.com/hibira-io/pixel-realm) (`AGENTS.md` there).

This repo is the Capacitor shell that ships pixel-realm's game client as an iPhone and Android app
(`io.hibira.aetherfall`, 「星核崩落」). It has no game code and no design docs.

## What Codex owns here

All final mobile art, delivered as source in `art-source/codex/<asset>/` with a `manifest.json` (prompt,
model, date, sizes), in a PR:

- App icon: one 1024×1024 master (no transparency, no text, readable at 60 px), plus Android adaptive icon
  foreground (with safe zone) and background layers.
- Splash / launch art for landscape and portrait.
- Store graphics: Google Play feature graphic 1024×500; screenshot frames and captions (Traditional Chinese
  first, then Japanese and English). Screenshots themselves must be real captures of the game.
- Touch-control art goes to **pixel-realm** (the HUD lives there), not here.

Original art only: no third-party game art, logos or look-alikes. Design questions about mobile UX (portrait
screens, notification wording, sign-in layout) are answered in pixel-realm's design docs.

Claude slices, sizes and wires the art into `ios/` and `android/`. Don't edit workflows, signing or native
code; open an issue if something there blocks you.
