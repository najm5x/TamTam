# TamTam

**TamTam** is a mobile race-and-capture board game for **Android and iOS**, built with **Flutter**.

The game draws inspiration from traditional race-and-capture board games while using its own gameplay rules, board geometry, movement routes, casting system, visual identity, and product architecture.

> **Project status:** MVP development — gameplay foundation is working, with visual design, UI integration, polish, and release preparation in progress.

---

## About TamTam

TamTam is designed around fast, strategic matches using:

- One piece per player
- A fixed 9×9 board
- Four player seats
- A shared central Finish
- A unique four-object White/Black casting system
- Exact-landing captures
- Classic and Blitz modes
- Local multiplayer
- Bot opponents

The project is being designed as a premium mobile game rather than a generic board-game implementation.

---

## Current MVP

The MVP supports or is being built around:

### Players

- 2 local players
- 4 local players
- 1 human vs 1 bot
- 1 human vs 3 bots

### Modes

- **Classic**
- **Blitz**

### Gameplay

- Canonical player routes
- Continuous movement
- Cell-by-cell piece animation
- White/Black TamTam casting
- Exact-landing capture
- Capture chains
- Capture-based extra casts
- Exact Finish requirement
- Bot play using the same game engine as human players
- Winner detection
- Rematch flow

---

## TamTam Casting System

TamTam does not use standard numeric dice.

Each cast uses **four independent two-sided objects**, with each object resolving to either White or Black.

The resulting combinations produce:

| Result | Movement |
| --- | --- |
| 3 White + 1 Black | 2 |
| 2 White + 2 Black | 4 |
| 1 White + 3 Black | 6 |
| 4 White | 16 |
| 4 Black | 32 |

The four binary results are generated independently. The game does not randomly choose uniformly between the five movement values.

---

## Board

TamTam uses a strict **9×9 physical board**.

- Columns: A–I
- Rows: 1–9
- Finish: E5
- Top Home: E1
- Right Home: I5
- Bottom Home: E9
- Left Home: A5

Movement follows canonical route data rather than artwork or image coordinates.

### Classic

- First round: 32 movement units
- Final journey: 78 movement units
- Unified Finish progress: 110

### Blitz

Blitz skips the preliminary 32-unit round.

- Starting progress: 32
- Finish progress: 110
- Active journey: 78 movement units

---

## Capture

A capture occurs only when a moving piece **lands exactly** on an opponent's physical board cell.

Passing over another piece does not capture it.

After a successful capture:

1. The captured piece returns Home.
2. Its progress resets.
3. The capturing player receives one extra cast.

A successful capture is the **only** event that grants an extra cast.

---

## Finish

The shared Finish is **E5**.

Exact landing is required.

If a cast would move a piece beyond the Finish, the piece does not move and the turn ends.

The first player to land exactly on Finish wins.

---

## Architecture

TamTam follows a core architectural principle:

> **One deterministic game engine, multiple rule profiles and presentation layers.**

Gameplay/domain logic is kept separate from:

- Flutter widgets
- Artwork
- Skins
- Animation
- Audio
- Persistence
- Networking

The game engine remains the authoritative source of gameplay truth.

Presentation systems display engine results but do not determine gameplay outcomes.

---

## Visual System

TamTam is being developed with an original premium visual identity.

The presentation system supports interchangeable:

- Board skins
- Piece skins
- Profile frames
- TamTam cube skins
- Cast tray skins
- Skin packs

Artwork never determines gameplay geometry.

The board remains a programmatic 9×9 coordinate system regardless of the artwork displayed underneath it.

---

## Asset Structure

Project artwork is organized under `assets/`, including areas such as:

```
assets/
├── branding/
├── dialogs/
├── fonts/
├── home/
├── setup/
├── shared/
├── skins/
└── victory/
```

Gameplay skin assets are presentation-only and must not modify movement routes or game rules.

---

## Technology

- **Flutter**
- **Dart**
- Android
- iOS
- Git
- GitHub

The architecture is intended to support a future online multiplayer backend without requiring the canonical TamTam game rules to be rewritten.

---

## Current Development Status

The core gameplay foundation has been manually tested for:

- Normal gameplay
- Bot gameplay
- Capture
- Board orientation
- Outer-route movement
- Inward-route movement
- Cell-by-cell movement
- Custom board selection
- Custom piece selection

Additional completed foundation work includes:

- Git repository initialization
- Baseline source control
- Winner-navigation fixes
- Functional rematch behavior
- Visual layout contracts
- Skin interfaces
- Calibration tooling
- UI and asset integration work

Current development is focused primarily on completing and polishing the **MVP presentation and user experience** while protecting the working gameplay engine from regressions.

---

## Development Principles

When contributing to TamTam:

1. Preserve canonical gameplay rules.
2. Do not derive gameplay geometry from artwork.
3. Keep domain logic independent from presentation.
4. Prefer small, targeted changes.
5. Avoid unrelated refactoring.
6. Protect already verified gameplay behavior.
7. Keep skins and cosmetics presentation-only.
8. Test gameplay after changes that could affect match behavior.
9. Do not introduce future systems prematurely.
10. Prioritize gameplay correctness over visual appearance.

---

## Roadmap

### MVP

Current priorities include:

- Complete Home/lobby experience
- Complete match setup presentation
- Polish gameplay HUD
- Finalize board presentation
- Polish TamTam casting animation
- Polish piece movement
- Capture feedback
- Winner presentation
- Settings
- Audio
- Haptics
- Game-feel effects
- QA and regression testing
- Android release preparation
- iOS release preparation

### Future

Planned future expansion may include:

- Online multiplayer
- Private tables
- Accounts and profiles
- Matchmaking
- Server-authoritative matches
- Reconnection
- Ranked play
- Leaderboards
- Tournaments
- Achievements
- Gems
- Cosmetic collections
- Board skins
- Piece skins
- Profile frames
- TamTam cube skins
- Cast tray skins
- Progression systems

These systems are intentionally deferred until the core MVP is stable and polished.

---

## Repository

This repository contains the active TamTam Flutter project, its source code, game assets, platform configuration, tests, and supporting project materials.

The `main` branch should represent a stable project checkpoint. Larger future changes should preferably be developed separately and merged after verification.

---

## Project Documentation

Detailed canonical gameplay rules, architectural constraints, development policies, and project decisions are maintained separately in the TamTam project documentation.

When documentation, code, old plans, screenshots, or artwork disagree, the canonical project rules and route data take precedence.

---

## Development Stage

**TamTam is currently under active development and is not yet a production release.**

© 2026 TamTam. All rights reserved.
