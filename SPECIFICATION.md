# Specification

**Spoiled Supper** is a from-scratch Flutter recreation of the 1983 Orchard Toys /
Macdonald 345 card game *Tummy Ache*. Ships as a web app first, designed for
desktop screen sizes, with a mobile-responsive PWA in v0.2.0, computer opponents
in v0.3.0, and native desktop/mobile app builds in v0.4.0. Open source (MIT).

---

## 1. Overview

Players race to build a complete meal on their place-setting board (Main, Drink,
two Sides, Dessert) by drawing cards from a shared pile, while avoiding — or
laughing at — the "Spoiled" cards mixed into the deck.

**Roadmap:**
- **v0.1.0** — Pass & Play (2–4 players, one device) — Web (desktop screen sizes)
- **v0.2.0** — Mobile-responsive PWA
- **v0.3.0** — Computer opponents
- **v0.4.0** — Native platform builds (Android, Windows/Linux desktop)
- **v0.5.0** — Online multiplayer

---

## 2. Key Decisions (recap)

| Area                    | Decision                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|-------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Framework               | Flutter (single codebase → Web, Android, Windows/Linux desktop; mobile-responsive PWA in v0.2.0, native desktop/Android app builds in v0.4.0). iOS and macOS are **out of scope** — both require a Mac (via Xcode) plus a paid Apple Developer account for iOS distribution. iOS users are still served by the v0.2.0 PWA via Safari's "Add to Home Screen," which needs neither                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| State management        | Top-level `StatefulWidget` + `InheritedWidget` (no external package)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| License                 | MIT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| Card art                | Original placeholder assets shipped in repo (text + colour-coded cards). Users may optionally supply their own locally-sourced images (from their own physical copy) via a local override system — never bundled, synced, or shared in-app                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Card data source        | **Confirmed** (categories, counts, items) against the maintainer's physical 1983 copy — see Appendix A. The physical cards show only images with no printed text; card names are entirely the maintainer's own original descriptions of the imagery                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| Online architecture     | Dart monorepo: shared `game_engine` package used by both the Flutter client and a lightweight self-hosted Dart WebSocket server (`shelf` + `web_socket_channel`)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Server hosting          | No committed/default server — each deployer hosts their own instance wherever suits them (home server, Fly.io, Cloud Run, VPS, etc.). README documents multiple options, endorses none as "the" server                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| Server address (client) | Configured at **runtime**, not build-time — first-launch prompt, persisted locally, editable in settings. Required for app-store distribution (one binary, many possible servers) and lets a user connect to different groups' servers without reinstalling                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| Access control          | Shared passcode (env-configured secret) required to *create* a room; joining an existing room by code stays open. Gates hosting, not play — each self-hosted instance sets its own passcode independently                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| Typography              | **Caprasimo** (Google Fonts) reserved for a small, fixed set of big, short, dramatic moments — the home-screen title, the win-screen headline, and the Spoiled reveal callout. **Fredoka** (Google Fonts) for everything else — card labels, buttons, selectors, turn banner, action log, settings text. Caprasimo is a single-weight decorative display face (no lighter cut exists), so it isn't suited to body/UI text; Fredoka carries that role throughout for a consistent, legible voice. Chosen over Baloo 2 since Baloo 2 is the Devanagari member of a ten-script family with Latin as a secondary pairing — Fredoka is Latin-first, more appropriate for an all-English game. Both freely licensed; typeface choice carries no copyright risk on its own (the earlier copyright concern was about not copying Orchard Toys' logo/wordmark, not typefaces generally) |

**Typography mapping (Flutter `TextTheme`):** all three `display` roles use
Caprasimo, each tied to one specific moment — `displayLarge` (home-screen title),
`displayMedium` (win-screen headline), `displaySmall` (Spoiled reveal
callout). Every other `TextTheme` role — `headlineLarge` through `labelSmall` —
uses Fredoka, including any persistent in-game header text (e.g. a "Spoiled!"
banner shown throughout play uses Fredoka via `headlineLarge`, since it's a
constant screen fixture, not one of the three rare dramatic moments). Keep the
three `display` roles scoped to exactly those three moments — don't reach for
`displaySmall` elsewhere just for extra visual weight, or Caprasimo's impact
dilutes, and it starts competing with `headlineLarge`.

```
Caprasimo → displayLarge (title), displayMedium (win headline),
            displaySmall (Spoiled callout) — three fixed moments only
Fredoka   → everything else (headlineLarge/Medium/Small,
            titleLarge/Medium/Small, bodyLarge/Medium/Small,
            labelLarge/Medium/Small)
```

**Architecture note:** the repo should be structured as a monorepo from Epic 1
(even though online play is v0.5.0), so the rules engine is never tangled with UI
code and can be reused by the server later without a rewrite.

```
spoiled_supper/
├── packages/
│   └── game_engine/     # pure Dart: Card, Category, Player, GameController, rules
├── app/                 # Flutter client
├── server/              # Dart WebSocket server (added in v0.5.0)
└── README.md
```

---

## 3. Asset & Copyright Policy (for README)

- This repository contains **no** Orchard Toys / Macdonald 345 artwork, branding, or trademarks.
- Spoiled Supper is an independent, fan-made project and is not affiliated with, endorsed by, or sponsored by Orchard Toys or Macdonald 345.
- Default cards are original placeholders (plain background, category colour, food name as text).
- Card names used throughout this project are the maintainer's own original descriptions of imagery on the physical cards, not printed text from them — the physical cards display only images, with no text at all.
- Users may personally supply their own card images (e.g. photographed/scanned from a copy they own) by placing files in a local override folder. This is a personal, local-only feature — the app never uploads, syncs, or shares these files.
- Contributors must not submit copyrighted third-party art, scans, or trademarked assets to this repository.

---

## 4. Out of Scope / Non-Goals (v0.1.0 – v0.5.0)

These are deliberate exclusions from the current roadmap, not oversights — noted
here so they don't get silently proposed or half-built by a future contributor.
Any of these could be revisited, but that should be a deliberate scope decision,
not an assumption.

- **User accounts / authentication** — play is via room codes and a creation passcode only; no persistent player identity or login system is planned.
- **AI difficulty levels** — a single baseline strategy only (Epic 11). Difficulty tiers were considered and deliberately cut given how little strategic depth the game has to tier.
- **Spectator mode** — online multiplayer (v0.5.0) is participants-only.
- **In-game chat** — not part of the v0.5.0 online multiplayer MVP scope.
- **Reconnection / session resume** — v0.5.0 disconnect handling is intentionally basic (detect and notify only); resuming a dropped player's session mid-game is not planned.
- **Native iOS / macOS builds** — excluded from v0.4.0's native platform builds (both require a Mac to build on; iOS also needs a paid Apple Developer account). iOS is still reachable via the v0.2.0 PWA.
- **A centrally hosted "official" server** — by design, no default or maintainer-run server is bundled or pointed to; every deployer (including the maintainer) self-hosts their own instance.

---

## Appendix A: Confirmed Card List (source: physical 1983 copy)

30 cards total — 20 standard (food/drink) + 10 Spoiled, 4 and 2 per category respectively.
Categories, item counts, and which foods appear are confirmed against the maintainer's
physical copy. The physical cards display only images, with no printed text at all —
so the card names below are entirely the maintainer's own original descriptions of the
imagery, not a transcription of anything printed on the cards. Spelling/phrasing here
(e.g. British vs. American spelling) is purely a styling choice.

### Standard Cards (20)

| Category (engine/UI) | Cards                                               |
|----------------------|-----------------------------------------------------|
| Desserts             | Fruit Salad, Ice Cream, Jelly, Strawberries         |
| Vegetables           | Baked Beans, Carrots, Peas, Tomatoes                |
| Mains                | Fish Fingers, Lamb Chops, Sausages, Steak Pie       |
| Carbohydrates        | Baked Potato, Boiled Potatoes, Chips, Mashed Potato |
| Drinks               | Grape Soda, Milk, Orange Soda, Water                |

### Spoiled Cards (10)

| Category (engine/UI) | Cards                          |
|----------------------|--------------------------------|
| Desserts             | Apple Core, Banana Skin        |
| Vegetables           | Dandelions, Mouldy Lettuce     |
| Mains                | Fish Bone, Leather Boot        |
| Carbohydrates        | Mouldy Potato, Potato Peelings |
| Drinks               | Bug Soda, Pond Water           |

**Note on naming:** during specification discussion, these two categories were initially
described as "Left Side" / "Right Side" — this was the maintainer's own shorthand
for their position on the physical board, **not** the box's printed terminology.
The underlying card split is consistently vegetables vs. carbohydrate/potato
dishes (confirmed across both standard and Spoiled cards), so the engine and
UI use `vegetables` / `carbohydrates` as category names. This stays accurate
regardless of how a given screen size arranges the plate (e.g. stacked instead of
side-by-side on narrow phone layouts in v0.2.0).
