# TamTam

**TamTam** is a premium mobile race-and-capture board game for **Android and iOS**, built with **Flutter**.

The game draws inspiration from traditional race-and-capture board games while using its own gameplay rules, board geometry, movement routes, casting system, visual identity, and product architecture.

> **Project status:** TamTam V2 specification is complete and implementation-ready. The previous V1 project remains the stable Git baseline while the V2 gameplay and board migration proceeds in a dedicated development branch.

---

## About TamTam

TamTam V2 is built around compact, strategic matches using:

- A fixed **5×5 board**
- Four player seats
- A shared central Finish
- A unique four-object White/Black casting system
- Independent pieces with per-piece progress
- Exact-landing captures
- Dynamic stack immunity
- Universal Home safety
- Classic, Rapid, and Blitz modes
- Local multiplayer
- Bot opponents

The project is designed as a premium mobile game rather than a generic board-game implementation.

---

## TamTam V2 Core Rules

### Players and Modes

| Mode | Pieces per player | Pieces required to win |
| --- | ---: | ---: |
| **Classic** | 4 | 4 |
| **Rapid** | 4 | 1 |
| **Blitz** | 1 | 1 |

All active pieces begin on the player's Home at progress `0`.

There is no unlock roll.

Each piece has its own independent progress and identity.

One cast moves exactly **one** selected unfinished piece.

---

## Board

TamTam V2 uses a strict **5×5 physical board**.

- Columns: **A–E**
- Rows: **1–5**
- Finish: **C3**
- Green Home / Entrance: **C1 / D1**
- Blue Home / Entrance: **E3 / E4**
- Yellow Home / Entrance: **C5 / B5**
- Red Home / Entrance: **A3 / A2**

Movement follows canonical route data rather than artwork or image coordinates.

All four Home cells are safe for **any player**.

A piece cannot be captured while occupying a Home cell, regardless of ownership.

---

## Journey

Every piece in every mode travels the same canonical journey:

- Start progress: `0`
- First round: **16 movement units**
- Second/final journey: **24 movement units**
- Finish progress: **40**

Movement is continuous.

A cast may cross the first-round boundary or the player Entrance without stopping.

Exact Finish is required.

There is no over-move, under-move, or bounce-back.

If one piece would overshoot but another unfinished piece has a legal move, the player must choose a legal piece.

If no unfinished piece can legally use the cast, no piece moves and the turn ends.

---

## TamTam Casting System

TamTam does not use standard numeric dice.

Each cast uses **four independent two-sided objects**, with each object resolving to either White or Black.

| Result | Movement |
| --- | ---: |
| 3 White + 1 Black | 2 |
| 2 White + 2 Black | 4 |
| 1 White + 3 Black | 6 |
| 4 White | 8 |
| 4 Black | 16 |

The four binary results are generated independently.

The game does **not** randomly choose uniformly between the five movement values.

---

## Stacking and Immunity

For ordinary active-board cells:

- 1 active piece is vulnerable
- 2 or more active pieces form an immune stack

Immunity is based on total active occupancy, regardless of ownership.

This means mixed-player stacks are allowed.

Any player may land on an already protected 2+ stack without capturing.

If occupancy later returns to exactly one active piece, that piece becomes vulnerable again unless it is standing on a universally safe Home cell.

Stacks never move as a group.

One cast always moves exactly one piece.

---

## Capture

A capture occurs only when a moving piece lands exactly on **one vulnerable opponent active piece**.

Passing over another piece does not capture it.

Landing on a protected 2+ stack does not capture.

After a successful capture:

1. Only the captured piece returns to its owner's Home.
2. Only that piece resets to progress `0`.
3. All other pieces retain their state.
4. The capturing player receives exactly one extra cast.

A successful capture is the **only** event that grants an extra cast.

Capture chains are allowed.

---

## Finish

The shared Finish is **C3**.

A piece finishes only by exact landing at progress `40`.

When a piece finishes:

- it becomes finished/inactive
- it is removed from active board occupancy
- it can no longer move
- it cannot capture
- it cannot be captured
- it does not affect stack immunity

The C3 Finish presentation is divided visually into four player triangles:

- Green: top
- Blue: right
- Yellow: bottom
- Red: left

Finished pieces are displayed in the appropriate player triangle for presentation only.

### Win Conditions

- **Classic:** first player to finish all 4 pieces wins
- **Rapid:** first player to finish 1 of their 4 pieces wins
- **Blitz:** first player to finish their single piece wins

---

## Canonical Routes

TamTam movement routes are programmatic and authoritative.

The machine-readable source of truth is:

`docs/v2/04_Canonical_Routes_V2.json`

The Green/Top route is the canonical base route.

The Blue, Yellow, and Red routes are exact 90-degree rotations of the same approved geometry.

Artwork never defines or alters movement routes.

---

## Board Layout Contract

The V2 board artwork and logical game geometry use the following fixed contract:

- Board source canvas: **1080×1080 px**
- Resolution metadata: **72 PPI**
- Margin: **50 px on all sides**
- Logical game area: **980×980 px**
- Grid: **5×5**
- Logical cell size: **196×196 px**
- C3 logical center: **(540, 540)**

Pieces are centered on their logical cells.

The visual Finish may be larger than C3, but it must remain a presentation overlay and must not alter the logical grid.

### Multiple Pieces on One Cell

| Active occupancy | Render size per piece |
| --- | ---: |
| 1 | 100% |
| 2 | 50% |
| 3 | 33.33% |
| 4 | 25% |
| 5 | 20% |
| 5+ | 20% with overlap |

For 5+ pieces, additional pieces overlap rather than shrinking below the 5-piece size.

Gameplay occupancy remains exact regardless of visual overlap.

---

## Bot Play

Bots use the same:

- game engine
- casting probabilities
- legal move generator
- canonical routes
- stacking rules
- safety rules
- capture rules

Bots do not cheat.

Bot move selection is safety-aware and may consider:

- immediate win
- finishing a piece
- capture opportunities
- creating or joining an immune stack
- preserving immunity
- avoiding unnecessary exposure
- switching pieces when continuing one becomes vulnerable
- progress toward Finish

---

## Architecture

TamTam follows a core architectural principle:

> **One deterministic gameplay engine, multiple rule profiles, and separate presentation layers.**

Gameplay/domain logic is kept separate from:

- Flutter widgets
- artwork
- skins
- animation
- audio
- haptics
- persistence implementation
- networking

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

Artwork is presentation-only.

It must never determine gameplay geometry, routes, Homes, Entrances, Finish behavior, capture, or stack immunity.

---

## Asset Structure

Project artwork is organized under `assets/`, including areas such as:

```text
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

Gameplay skin assets must not modify movement routes or game rules.

---

## Technology

- **Flutter**
- **Dart**
- Android
- iOS
- Git
- GitHub

The architecture is intended to support future online multiplayer without requiring the canonical TamTam gameplay rules to be rewritten.

---

## Current Development Status

The previous V1 project is preserved as the stable Git baseline.

Completed V1 foundation work includes:

- working local gameplay foundation
- bot gameplay
- capture flow
- winner detection
- rematch flow
- board orientation and route movement
- cell-by-cell movement animation
- custom board and piece selection
- rapid-cast interaction locking
- visual layout contracts
- skin interfaces
- calibration tooling
- premium UI and asset integration work

TamTam V2 is now fully specified and the next development phase is the controlled V1 → V2 migration.

### V2 Migration Order

1. Audit obsolete V1 assumptions
2. Migrate canonical routes
3. Migrate cast values
4. Add independent per-piece domain state
5. Add Classic / Rapid / Blitz rule profiles
6. Add legal piece selection
7. Implement occupancy, stack immunity, Home safety, and capture
8. Implement finished-piece state and V2 win conditions
9. Upgrade bot strategy
10. Convert presentation to the 5×5 board and multi-piece rendering
11. Run V2 regression tests
12. Perform manual gameplay verification

The V2 migration should not begin as a cosmetic board resize.

Domain and route correctness come first.

---

## Development Principles

When contributing to TamTam:

1. Follow the latest explicit product decision.
2. Treat canonical V2 route data as authoritative.
3. Do not derive gameplay geometry from artwork.
4. Keep domain logic independent from presentation.
5. Prefer small, targeted changes.
6. Avoid unrelated refactoring.
7. Keep skins and cosmetics presentation-only.
8. Test gameplay after changes that affect match behavior.
9. Do not introduce future systems prematurely.
10. Prioritize gameplay correctness over visual appearance.

---

## Repository and Branch Strategy

The `main` branch should remain a stable project checkpoint.

Before V2 implementation:

- preserve/tag the stable V1 state
- create a dedicated V2 migration branch
- commit the authoritative V2 documentation
- perform the V1 source audit before changing gameplay code

Large V2 changes should be verified before merging back into `main`.

---

## Project Documentation

Authoritative V2 project documentation is maintained under the V2 documentation set.

Recommended repository location:

```text
docs/
└── v2/
    ├── 00_READ_ME_FIRST_V2.md
    ├── 01_Game_Rules_Constitution_V2.md
    ├── 02_Project_Description_V2.md
    ├── 03_Canonical_Routes_V2.md
    ├── 04_Canonical_Routes_V2.json
    ├── 05_Technical_Architecture_V2.md
    ├── 06_MVP_Scope_V2.md
    ├── 07_Test_and_Verification_Plan_V2.md
    ├── 08_Gemini_Antigravity_Master_Prompt_V2.md
    ├── 09_Visual_Layout_Contract_V2.md
    ├── TamTam_Claude_Master_Handoff_Prompt_V2.md
    ├── TamTam_Project_Instructions_V2.md
    ├── TamTam_Source_Audit_for_Claude_V2.md
    └── project_manifest_V2.json
```

When sources disagree, use this priority:

1. Latest explicit user decision
2. `04_Canonical_Routes_V2.json`
3. `01_Game_Rules_Constitution_V2.md`
4. `TamTam_Project_Instructions.md`
5. Current Flutter source
6. Older V1 documentation, prompts, screenshots, plans, or artwork

---

## Roadmap

### V2 MVP

Current priorities:

- V1 source audit
- V2 gameplay migration
- 5×5 board integration
- multi-piece interaction and presentation
- Rapid mode
- stack immunity feedback
- Finish triangle presentation
- safety-aware bot behavior
- gameplay HUD polish
- casting animation polish
- piece movement polish
- capture feedback
- winner presentation
- settings
- audio
- haptics
- game-feel effects
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

These systems remain deferred until the V2 MVP is stable and polished.

---

## Development Stage

**TamTam is currently under active development and is not yet a production release.**

© 2026 TamTam. All rights reserved.
