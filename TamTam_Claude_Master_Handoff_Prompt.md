# Claude Fable 5 — TamTam Source-Aware Master Handoff Prompt

You are taking over an existing Flutter mobile board-game project named **TamTam** from another coding agent.

Your task is **not** to rebuild the game from scratch and not to blindly trust prior completion claims. You must first audit the actual repository, protect the working game engine, then establish a durable visual layout + cosmetic skin architecture before more board/profile/dice artwork is created.

## Operating mode

Work like a senior Flutter/game-systems engineer taking ownership of a live codebase.

Rules:

1. Inspect before editing.
2. Source, canonical route JSON, automated tests, and actual debug behavior outrank stale Markdown claims.
3. Do not rewrite working domain logic without a demonstrated defect.
4. Make changes in small testable phases.
5. Keep gameplay truth independent from rendering and assets.
6. Never infer movement from artwork.
7. Do not build an APK unless the user explicitly asks later.
8. Do not claim success without running the checks available in the actual repository.

---

# A. Repository discovery — do this first

Open the actual local TamTam repository and inventory it.

The audit snapshot supplied to the reviewer contained these important files:

```text
assets/routes/04_Canonical_Routes.json

lib/main.dart

lib/domain/
  engine/
    cast_generator.dart
    tamtam_engine.dart
  models/
    board_cell.dart
    cast_result.dart
    game_event.dart
    game_state.dart
    player_state.dart
    rule_profile.dart
    seat.dart
  routes/
    canonical_routes.dart

lib/application/
  controllers/
    player_controller.dart
    human_controller.dart
    bot_controller.dart
  storage/
    match_storage.dart

lib/presentation/
  theme/app_theme.dart
  screens/
    home_screen.dart
    match_setup_screen.dart
    match_screen.dart
    result_screen.dart
    settings_screen.dart
  widgets/
    board_widget.dart
    board_cell_view.dart
    cast_area_widget.dart
    cast_tray.dart
    dev_overlay.dart
    pause_dialog.dart
    player_card.dart
    player_hud.dart
    tamtam_cube.dart

test/
tool/generate_routes.dart
```

The uploaded review snapshot did not include `pubspec.yaml`, `pubspec.lock`, or the full platform folders. The user's real local repository may contain them. Locate them before dependency/build decisions.

Before editing, report:
- repository root;
- Flutter/Dart versions if resolvable;
- dependencies from `pubspec.yaml`;
- complete source tree;
- current git status if git is present;
- current `flutter analyze` result;
- current `flutter test` result.

Do not build an APK.

---

# B. Canonical TamTam rules — these are authoritative

Do not resurrect obsolete 80/112 assumptions.

## Board

- 9×9 board
- columns A..I left-to-right
- rows 1..9 top-to-bottom
- Finish = E5

Homes:
- Top = E1
- Right = I5
- Bottom = E9
- Left = A5

Gates:
- Top = H1
- Right = I8
- Bottom = B9
- Left = A2

Pre-finish route cells:
- Top = E4
- Right = F5
- Bottom = E6
- Left = D5

## Progress model

Classic:
- starts at unified progress 0
- first-round boundary at progress 32
- second/final journey length = 78
- exact Finish = unified progress 110

Blitz:
- skips the preliminary 32
- starts at unified progress 32
- exact Finish = 110

Top canonical landmarks:
- 0 = E1
- 32 = E1
- 61 = H1 gate
- 62 = H2 first inward cell
- 109 = E4
- 110 = E5 Finish

Other seats are encoded explicitly in canonical route data.

## Direction

Do not apply one global circulation direction.

- Outer/perimeter travel follows the canonical anti-clockwise route.
- Once the piece enters its gate, the canonical route turns into the clockwise inward route toward E5.

The route arrays already encode this. Follow array order. Do not reverse arrays.

## Cast

Four independent binary White/Black objects.

- 3W + 1B = 2
- 2W + 2B = 4
- 1W + 3B = 6
- 4W = 16
- 4B = 32

Do not choose uniformly among five values.

## Movement

A cast is continuous.

Do not stop or discard remainder:
- at progress 32;
- at a gate;
- while entering the inward route.

Pieces visually traverse every intermediate canonical route cell.

## Capture

- capture only by exact final landing;
- passing over an opponent does nothing;
- Homes are safe;
- multiple pieces may share a Home;
- captured Classic player resets to 0;
- captured Blitz player resets to 32;
- successful capture is the only extra-cast trigger;
- capture chains may create successive extra casts.

## Finish

Exact landing on progress 110 / E5 is required.

Overshoot:
- no movement;
- turn ends.

First player to exact Finish wins.

`assets/routes/04_Canonical_Routes.json` is the authoritative geometry source.

---

# C. Working behavior to preserve

Treat these systems as regression-sensitive:

- canonical four-player route data;
- board orientation Row 1 top / Row 9 bottom;
- bots;
- capture behavior;
- Home safety;
- Classic and Blitz starts;
- exact Finish;
- anti-clockwise outer movement;
- clockwise inward movement after the gate;
- cell-by-cell visual piece traversal;
- binary cast probability model.

Do not alter them as part of a cosmetic/layout refactor unless a test or direct reproduction demonstrates a defect.

---

# D. Known source issues from the takeover audit

Verify every item against the current repository before changing it.

## D1. Match-finished navigation

In the audited `match_screen.dart`, `_afterMovement()` only handled `turnFinished` / `animatingMove`.

A winning transition is already `matchFinished`, so result navigation can be skipped after the final movement animation.

Fix orchestration so:

```text
exact landing
→ animate final route cells
→ commit matchFinished state
→ winner feedback
→ ResultScreen exactly once
```

Do not change the engine's win semantics.

## D2. REMATCH semantics

The audited `ResultScreen` used `Navigator.pop()` for REMATCH.

Implement a real rematch:
- same match type;
- same seats;
- same human/bot roles;
- same rule profile;
- all players reset to mode start;
- winner cleared;
- extra casts cleared;
- stable waiting state.

Do not resume stale winner state.

## D3. Persistence not integrated

`MatchStorage` exists but was unused by production source in the audit snapshot.

Wire save/resume only at stable logical boundaries.

Home should show Continue Match only when a valid unfinished save exists.

Do not save mid-animation.

## D4. Controller architecture not integrated

`PlayerController`, `HumanController`, and `BotController` existed but `MatchScreen` performed bot scheduling and cast generation directly.

Do not rush into a broad rewrite.

First protect current behavior with tests, then move non-visual match orchestration into an application-level coordinator/controller if it improves maintainability.

`MatchScreen` should not remain the permanent owner of:
- domain transitions;
- bot scheduling;
- persistence;
- navigation;
- animation choreography;
- dev tools;
- all layout.

## D5. Dead legacy widgets

Audit and remove/deprecate unused legacy widgets such as:
- `cast_area_widget.dart`
- `player_card.dart`

Do not leave multiple competing UI systems.

## D6. Settings and navigation placeholders

Do not leave buttons that look functional but do nothing.

Settings can remain small, but should have a real model for future:
- sound;
- haptics;
- animation speed;
- selected cosmetic IDs.

---

# E. Current product design direction

TamTam should feel like a polished mobile game, not a generic Material utility app.

Use Ludo-style game apps only as inspiration for:
- strong visual hierarchy;
- big play-mode cards;
- lively turn feedback;
- compact player identity;
- playful animations.

Do not copy any copyrighted game assets, branding, exact artwork, economy, or board design.

Normal match UI:

- player identity is positioned according to seat;
- no `(top)`, `(bottom)`, etc. labels;
- no raw progress text in normal UI;
- show player-color icon/frame + Player 1/2/etc.;
- active player gets subtle pulse/highlight;
- pieces are visibly larger than early MVP;
- board remains the dominant visual element.

Board semantics:

- full player color only on Home;
- gate cell remains neutral with a tiny low-opacity player-color inward arrow;
- do not randomly color route cells;
- Finish E5 is shared/neutral;
- pre-finish must not look like another full player-color Home.

Cast UI:

- four TamTam binary cubes, not standard pip dice;
- cubes tumble before movement;
- cast tray/frame uses active-player color as dynamic accent;
- cube skins must not affect probabilities.

---

# F. PRIMARY NEXT TASK — Freeze the visual layout before designing skins

Do not create new artistic board/frame/dice assets yet.

First implement a **Visual Layout Contract**.

Core principle:

> Layout owns geometry. Skins only fill fixed slots.

All future skins must snap into the same geometry without per-skin resizing or manual repositioning.

---

# G. Board geometry contract

Create a presentation-only canonical board design space:

```text
Board asset canvas: 1080 × 1080
Playable grid rect: x=54, y=54, width=972, height=972
Grid: 9 × 9
Cell: 108 × 108 design units
```

Cell mapping:

```text
column A..I -> index 0..8
row 1..9   -> index 0..8

centerX = 54 + (columnIndex + 0.5) * 108
centerY = 54 + (rowIndex + 0.5) * 108
```

Reference centers:

```text
A1 = (108,108)
E1 = (540,108)
H1 = (864,108)
A5 = (108,540)
E5 = (540,540)
I5 = (972,540)
B9 = (216,972)
E9 = (540,972)
I9 = (972,972)
```

Create one authoritative `BoardGeometry` / `VisualLayoutContract`.

Do not scatter these ratios/numbers through widgets.

The domain layer must know nothing about this design-space geometry.

---

# H. Board skin contract

A board skin is presentation artwork only.

Every board skin:
- uses 1080×1080;
- respects the same playable-grid rect;
- may decorate the neutral board/frame;
- may use texture/pattern/background;
- must not contain pieces;
- must not contain player names;
- must not contain route numbers;
- must not bake in gate arrows;
- must not change cell centers;
- must not redefine Homes/Gates/Finish.

Recommended layering:

```text
Board background skin
→ programmatic 9×9 gameplay grid / semantic overlays
→ pieces
→ optional board foreground/frame overlay
```

Support a `BoardSkin` with optional background and foreground assets so ornate frames do not force gameplay coordinates into an image.

Do not use the bitmap itself as hit-testing or movement truth.

---

# I. Player/profile frame contract

Player frames are separate cosmetic assets.

Display frame size:

```text
frameSize = 0.16 × displayedBoardSize
```

Anchors relative to board top-left:

```text
Top center    = (0.50B, -0.03B)
Right center  = (1.03B, 0.50B)
Bottom center = (0.50B, 1.03B)
Left center   = (-0.03B, 0.50B)
```

For 2-player matches:
- show Top and Bottom;
- hide side frames;
- let board use more screen width.

For 4-player matches:
- show all four;
- use a fixed 4P layout profile that scales the board enough to keep side frames visible.

Do not resize assets manually by skin.

## Frame artwork

Every frame skin:

```text
512 × 512 transparent canvas
```

Reserve stable internal safe areas:
- portrait/icon safe circle: around center (256,210), diameter ~300
- nameplate safe rect: x=80, y=360, width=352, height=90

Player text is rendered by Flutter.

Never bake "Player 1" or usernames into artwork.

---

# J. Piece contract

Every piece skin:

```text
512 × 512 transparent canvas
```

Logical anchor:
- exact center of current board cell.

Normal displayed piece size:
- `0.68 × cell size`

Safe-cell stacked size:
- approximately `0.44 × cell size`

Changing piece art must never affect route coordinates.

---

# K. Gate/Home/Finish contract

Keep semantic gameplay overlays programmatic.

Home:
- full seat-color fill.

Gate:
- neutral cell;
- small inward arrow;
- size ≈ `0.20 × cell size`;
- opacity ≈ 0.32–0.40;
- seat color.

Finish E5:
- shared neutral finish style.

Latest rule:
- do not fully color pre-finish cells.

A board skin may not move or redefine these overlays.

---

# L. Cast tray contract

Every cast-tray skin:

```text
1000 × 240 transparent canvas
```

Display width:
- approximately `0.75 × displayedBoardSize`

Preserve aspect ratio.

The tray skin is neutral.

Active player accent:
- border/pulse/tint drawn programmatically using active seat color.

Do not create separate tray images for Top/Right/Bottom/Left.

Define four fixed cube slots inside the tray layout.

---

# M. TamTam cube/dice skin contract

Every cube/dice skin uses a fixed square source canvas, preferably:

```text
512 × 512
```

It remains a binary TamTam object:
- White result face
- Black result face

No numeric pips.

The visual cube is independent of cast generation.

Different future cube skins may alter:
- face texture;
- body material;
- edge decoration;
- animation style within approved bounds.

They may not alter:
- face outcome;
- cast value;
- probability;
- slot position;
- logical timing of the engine.

---

# N. Skin types and source structure

Create presentation-only types similar to:

```text
BoardSkin
ProfileFrameSkin
PieceSkin
DiceSkin
CastTraySkin
TamTamSkinPack
SkinCatalog
```

Suggested organization:

```text
lib/presentation/
├── layout/
│   ├── visual_layout_contract.dart
│   ├── board_geometry.dart
│   └── match_layout.dart
├── skins/
│   ├── board_skin.dart
│   ├── profile_frame_skin.dart
│   ├── piece_skin.dart
│   ├── dice_skin.dart
│   ├── cast_tray_skin.dart
│   ├── skin_pack.dart
│   └── skin_catalog.dart
└── widgets/
    ├── table/
    │   ├── tamtam_table_stage.dart
    │   ├── board_surface.dart
    │   └── player_frame_slot.dart
    └── cast/
        ├── cast_tray.dart
        └── tamtam_cube.dart
```

Do not import presentation skins into `domain/`.

For MVP, use a compile-time/local catalog. Do not build a store/backend/economy.

---

# O. Build a calibration screen before art

Create a DEBUG-ONLY `VisualCalibrationScreen`.

Its purpose is to validate positions/scales on the user's real phone before any new board or frame artwork is produced.

Show:

- 1080 board canvas boundary;
- playable 972×972 grid rect;
- 9×9 cells;
- cell centers;
- four Homes;
- four gates and directions;
- E5;
- profile-frame rectangles;
- piece bounding circle;
- cast tray rectangle;
- four cube-slot rectangles;
- measured normalized ratios.

Use ugly/high-contrast temporary debug colors deliberately.

Add a way to preview:
- 2P layout;
- 4P layout;
- portrait phone widths;
- currently selected default skin placeholders.

This screen must be excluded/inaccessible in release builds.

Stop the visual-layout phase after the calibration screen is ready for user inspection.

Do not design rich skins before layout approval.

---

# P. Responsive layout profiles

Do not force one board scale for every match topology.

Define stable responsive profiles.

## 2-player

Priority:
- largest practical board;
- Top frame above;
- Bottom frame below;
- no side-frame space reserved.

## 4-player

Priority:
- all four frames visible;
- board remains square;
- side frames never obscure playable grid;
- board scales down according to a fixed 4P rule rather than ad-hoc pixel tweaks.

Use `LayoutBuilder` and ratios from the contract.

Do not hardcode dimensions for one Samsung screen.

Respect SafeArea.

---

# Q. Refactoring discipline

Before modifying `MatchScreen` heavily:

1. add/retain regression tests;
2. isolate layout/skin work from engine work;
3. keep movement animation canonical;
4. keep bot behavior unchanged;
5. keep cast generation unchanged.

If you introduce `MatchController`/`MatchCoordinator`, migrate in small commits/steps.

At all times the project should remain testable.

Avoid a "big bang" rewrite.

---

# R. Required tests

Keep existing domain tests.

Add tests for:

## Board geometry
- A1 maps top-left;
- I9 maps bottom-right;
- E5 maps exact center;
- cell centers use the contract formula.

## Semantic overlays
- E1/I5/E9/A5 are Homes;
- H1/I8/B9/A2 gate arrows point inward;
- E5 is Finish;
- pre-finish cells are not full Home-color fills.

## Route-to-render mapping
- Top progress 0 renders E1;
- Top 18 renders G9;
- Bottom 26 renders A7;
- Top 60→62 animation traverses I1→H1→H2.

## Layout
- 2P hides side player slots;
- 4P shows all four;
- profile frames do not overlap playable-grid rect according to contract.

## Result/rematch
- matchFinished reaches ResultScreen orchestration;
- rematch produces fresh state with same match configuration.

## Persistence
- stable save/resume if you wire it in this phase;
- no mid-animation duplication.

Do not replace manual visual inspection with tests alone.

---

# S. Commands and build restrictions

You may run:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

when appropriate in the actual repository.

Do not run:

```bash
flutter build apk
```

Do not sign/install/release-package the app.

The user will package/debug Android builds manually.

---

# T. Work sequence

Execute in this order:

## Phase 0 — Audit
- inspect full repo;
- analyze/test baseline;
- report differences from this handoff.

## Phase 1 — Protect/fix
- protect engine behavior;
- verify known orchestration issues;
- fix result navigation/rematch if reproduced;
- remove only clearly dead duplicate UI.

## Phase 2 — Layout contract
- implement centralized board/layout geometry;
- no rich art.

## Phase 3 — Skin interfaces
- board/frame/piece/dice/tray contracts;
- placeholder skins only.

## Phase 4 — Calibration
- implement VisualCalibrationScreen;
- run it in debug;
- stop for user visual approval.

## Phase 5 — Only after explicit user approval
- begin rich board skins/profile frames/dice styles;
- all artwork must fit the frozen contracts.

Do not jump directly to Phase 5.

---

# U. Completion report for this handoff phase

At the end of Phases 0–4, report:

1. actual repository root;
2. baseline analyze/test results;
3. files modified;
4. source issues found and whether fixed;
5. confirmation canonical route JSON was untouched;
6. confirmation engine semantics were preserved;
7. final Visual Layout Contract values;
8. 2P and 4P layout behavior;
9. skin interfaces created;
10. calibration screen path/activation method;
11. tests added and results;
12. any unresolved layout concern that requires the user's visual decision;
13. exact command the user should run to inspect the calibration screen.

Do not claim the visual system is approved. The user must approve calibration before skin artwork begins.
