# Spoiled Supper

**Spoiled Supper** is a from-scratch Flutter recreation of the 1983 Orchard
Toys / Macdonald 345 card game *Tummy Ache*. Players race to build a complete
meal on their place-setting board (Main, Drink, two Sides, Dessert) by drawing
cards from a shared pile, while avoiding — or laughing at — the "Spoiled"
cards mixed into the deck.

Ships as a web app first, designed for desktop screen sizes, with a
mobile-responsive PWA, computer opponents, native desktop/mobile app builds,
and online multiplayer following on the roadmap below. Open source, MIT
licensed.

This is an independent, fan-made project. It is **not affiliated with,
endorsed by, or sponsored by** Orchard Toys or Macdonald 345 — see
[Assets & Copyright Policy](#assets--copyright-policy) below.

---

## Table of Contents

- [Roadmap](#roadmap)
- [Repository Layout](#repository-layout)
- [Getting Started](#getting-started)
- [Key Technical Decisions](#key-technical-decisions)
- [Assets & Copyright Policy](#assets--copyright-policy)
- [Out of Scope / Non-Goals](#out-of-scope--non-goals)
- [Contributing](#contributing)

---

## Roadmap

| Version    | Milestone                                                          |
|------------|--------------------------------------------------------------------|
| **v0.1.0** | Pass & Play (2–4 players, one device) — Web (desktop screen sizes) |
| **v0.2.0** | Mobile-responsive PWA                                              |
| **v0.3.0** | Computer opponents                                                 |
| **v0.4.0** | Native platform builds (Android, Windows/Linux desktop)            |
| **v0.5.0** | Online multiplayer                                                 |

iOS and macOS native builds are out of scope (see
[Out of Scope / Non-Goals](#out-of-scope--non-goals)); iOS users are served
by the v0.2.0 PWA via Safari's "Add to Home Screen."

For the full design rationale behind these decisions, see
[`SPECIFICATION.md`](SPECIFICATION.md).

---

## Repository Layout

This repository is structured as a Dart/Flutter monorepo from the start,
even though online play isn't planned until v0.5.0, so the rules engine
stays decoupled from UI code and can be reused by a server later without a
rewrite:

```
spoiled-supper-lotto-game/
├── packages/
│   └── game_engine/     # pure Dart: Card, Category, Player, GameController, rules
├── app/                 # Flutter client (web first, then PWA/desktop/mobile)
├── server/              # Dart WebSocket server (added in v0.5.0)
├── SPECIFICATION.md      # full project specification and key decisions
└── README.md             # this file
```

- **`packages/game_engine`** — the shared, pure-Dart rules engine (cards,
  categories, players, game state, turn logic). Has no dependency on
  Flutter or the UI, so it can be used unmodified by both the app and the
  future server.
- **`app`** — the Flutter client. See [`app/README.md`](app/README.md) for
  app-specific setup and run instructions.
- **`server`** — a lightweight, self-hosted Dart WebSocket server (`shelf` +
  `web_socket_channel`), arriving in v0.5.0 to support online multiplayer.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK
  `^3.0.0`, bundled with Flutter)
- A web browser (Chrome recommended) for running the v0.1.0 web target

### Running the app

```bash
cd app
flutter pub get
flutter run -d chrome
```

See [`app/README.md`](app/README.md) for more detail on the Flutter client,
including build and test commands.

---

## Key Technical Decisions

A short summary of the decisions that shape this codebase — see
[`SPECIFICATION.md`](SPECIFICATION.md) for full rationale on each:

- **Framework** — Flutter, single codebase targeting Web, Android, and
  Windows/Linux desktop. iOS and macOS native builds are excluded (see
  [Out of Scope](#out-of-scope--non-goals)).
- **State management** — a top-level `StatefulWidget` + `InheritedWidget`;
  no external state management package.
- **Card art** — original placeholder assets (text and colour-coded cards)
  ship in the repo. Users may optionally supply their own locally sourced
  images via a local override system — never bundled, synced, or shared
  in-app.
- **Card data** — confirmed against the maintainer's physical 1983 copy; see
  Appendix A of [`SPECIFICATION.md`](SPECIFICATION.md) for the full card
  list.
- **Online architecture (v0.5.0)** — a shared `game_engine` package used by
  both the Flutter client and a self-hosted Dart WebSocket server. There is
  no centrally hosted "official" server — every deployer self-hosts their
  own instance.
- **Access control (v0.5.0)** — a shared, env-configured passcode is
  required to *create* a room; joining an existing room by code stays open.
- **Typography** — **Caprasimo** (Google Fonts) reserved for three fixed,
  dramatic moments (home-screen title, win-screen headline, Spoiled reveal
  callout); **Fredoka** (Google Fonts) for everything else — card labels,
  buttons, selectors, turn banner, action log, settings text, and any
  persistent in-game headers.
- **License** — MIT.

---

## Assets & Copyright Policy

- This repository contains **no** Orchard Toys / Macdonald 345 artwork,
  branding, or trademarks.
- Spoiled Supper is an independent, fan-made project and is not affiliated
  with, endorsed by, or sponsored by Orchard Toys or Macdonald 345.
- Default cards are original placeholders (plain background, category
  colour, food name as text).
- Card names used throughout this project are the maintainer's own original
  descriptions of imagery on the physical cards, not printed text from
  them — the physical cards display only images, with no text at all.
- Users may personally supply their own card images (e.g. photographed or
  scanned from a copy they own) by placing files in a local override
  folder. This is a personal, local-only feature — the app never uploads,
  syncs, or shares these files.
- Contributors **must not** submit copyrighted third-party art, scans, or
  trademarked assets to this repository.

---

## Out of Scope / Non-Goals

These are deliberate exclusions from the current roadmap (v0.1.0 – v0.5.0),
not oversights — noted here so they don't get silently proposed or
half-built by a future contributor. Any of these could be revisited, but
that should be a deliberate scope decision, not an assumption.

- **User accounts / authentication** — play is via room codes and a
  creation passcode only; no persistent player identity or login system is
  planned.
- **AI difficulty levels** — a single baseline strategy only. Difficulty
  tiers were considered and deliberately cut given how little strategic
  depth the game has to tier.
- **Spectator mode** — online multiplayer (v0.5.0) is participants-only.
- **In-game chat** — not part of the v0.5.0 online multiplayer MVP scope.
- **Reconnection / session resume** — v0.5.0 disconnect handling is
  intentionally basic (detect and notify only); resuming a dropped player's
  session mid-game is not planned.
- **Native iOS / macOS builds** — excluded from v0.4.0's native platform
  builds (both require a Mac to build on; iOS also needs a paid Apple
  Developer account). iOS is still reachable via the v0.2.0 PWA.
- **A centrally hosted "official" server** — by design, no default or
  maintainer-run server is bundled or pointed to; every deployer (including
  the maintainer) self-hosts their own instance.

---

## Contributing

This project is in early development (pre-v0.1.0). Issues and pull requests
are welcome — please read [`SPECIFICATION.md`](SPECIFICATION.md) first to
understand the design decisions already made, especially around scope
(see [Out of Scope / Non-Goals](#out-of-scope--non-goals)) and the
[Assets & Copyright Policy](#assets--copyright-policy) if you're
contributing artwork or card data.
