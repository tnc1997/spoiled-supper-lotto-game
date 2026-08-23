# Spoiled Supper — App

This is the Flutter client for **Spoiled Supper**, a from-scratch recreation
of the 1983 Orchard Toys / Macdonald 345 card game *Tummy Ache*. For the
project overview, roadmap, repository layout, and full design rationale, see
the [top-level README](../README.md) and
[`SPECIFICATION.md`](../SPECIFICATION.md).

This app is **not affiliated with, endorsed by, or sponsored by** Orchard
Toys or Macdonald 345 — see the top-level
[Assets & Copyright Policy](../README.md#assets--copyright-policy).

---

## Table of Contents

- [Current Status](#current-status)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Client-Specific Design Notes](#client-specific-design-notes)

---

## Current Status

The app targets **v0.1.0**: Pass & Play (2–4 players, one device), Web only,
designed for desktop screen sizes. Later milestones — mobile-responsive PWA
(v0.2.0), computer opponents (v0.3.0), native desktop/mobile builds
(v0.4.0), and online multiplayer (v0.5.0) — are tracked in the
[top-level README's roadmap](../README.md#roadmap).

The game logic (cards, categories, players, turn rules) lives in the
sibling [`packages/game_engine`](../packages/game_engine) package, kept
independent of Flutter/UI code so it can be reused by a future server
(v0.5.0) without a rewrite.

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK
  `^3.0.0`, bundled with Flutter)
- A web browser (Chrome recommended) — this app currently targets Web only

Check your setup with:

```bash
flutter doctor
```

---

## Getting Started

From this `app/` directory:

```bash
# Fetch dependencies (including the local game_engine package)
flutter pub get

# Run in a browser
flutter run -d chrome

# Run tests
flutter test

# Analyze the code
flutter analyze

# Build a release web bundle
flutter build web
```

---

## Project Structure

```
app/
├── lib/
│   └── main.dart      # app entry point
├── web/                # web-specific assets (index.html, icons, manifest)
├── pubspec.yaml        # dependencies and Flutter configuration
└── README.md            # this file
```

---

## Client-Specific Design Notes

The state management approach, typography mapping, card art policy, and
runtime server configuration are documented once, in the top-level
[Key Technical Decisions](../README.md#key-technical-decisions) — this
avoids the two READMEs drifting out of sync. A couple of notes specific to
working in this Flutter client:

- No external state management package (e.g. Provider, Riverpod, Bloc) is
  used or should be added — see the top-level README for the
  `StatefulWidget` + `InheritedWidget` rationale.
- Typography is configured via Flutter's `TextTheme` — see the top-level
  README's typography mapping for which `TextTheme` role maps to which
  font and moment before adding new text styles.

For the asset and copyright rules that apply to any card art or data added
to this app, see the top-level
[Assets & Copyright Policy](../README.md#assets--copyright-policy).
