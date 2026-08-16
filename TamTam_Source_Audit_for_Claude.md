# TamTam Source Audit for Claude Fable 5 Handoff

## Scope

This audit is based on the uploaded `TT.zip` snapshot of the current TamTam Flutter source.

The snapshot contains:
- `lib/` domain, application, and presentation source
- canonical route JSON and generated Dart routes
- domain/application/widget tests
- route generator tool
- Android manifest and some Gradle configuration
- prior implementation plan, task tracker, and walkthrough

The snapshot does **not** contain `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, the complete normal Flutter `android/` directory, or iOS project files. Because of that, this snapshot is sufficient for source review and handoff planning, but not for an independent clean `flutter pub get`, `flutter analyze`, or `flutter test` run outside the user's actual repository.

## 1. What is strong and should be treated as frozen unless a demonstrated bug exists

### Canonical route model

`assets/routes/04_Canonical_Routes.json` is coherent with the current agreed TamTam geometry:

- Board: 9×9
- Classic start: 0
- First-round boundary: 32
- Second/final journey: 78
- Classic finish: 110
- Blitz start: 32
- Finish cell: E5
- Gate unified progress: 61
- Cast values: 2, 4, 6, 16, 32

All four player routes are explicitly present and rotated consistently.

`lib/domain/routes/canonical_routes.dart` is generated from that JSON and the test suite includes JSON-parity checks.

### Cast model

`CastResult` correctly derives movement from four binary White/Black faces:

- 3 white / 1 black = 2
- 2 white / 2 black = 4
- 1 white / 3 black = 6
- 4 white = 16
- 4 black = 32

The test suite covers all 16 binary combinations.

### Core engine

`TamTamEngine` currently implements the important core rules:

- continuous progress rather than stopping at Home or gate
- exact finish
- overshoot = no movement
- capture by exact final landing
- Home safety
- reset to mode start on capture
- capture-only extra cast
- chained extra casts
- canonical route-based animation path emission

This area should not be redesigned during the UI/cosmetic architecture phase.

### Board coordinate orientation

`BoardWidget._toCoordinate()` currently maps:

- index row 0 -> row 1 at top
- columns left-to-right A..I
- rows top-to-bottom 1..9

This is the correct canonical orientation.

### Cell-by-cell movement presentation

`MatchScreen` uses the engine-emitted `PieceMovementPlanned.path` and animates every intermediate coordinate in sequence.

The current step timing is:
- <= 6 moves: 100 ms/cell
- <= 16 moves: 75 ms/cell
- longer moves: 60 ms/cell

Do not regress this into destination teleportation.

### Current semantic board markers

The source currently renders:
- full player color on Home only
- low-opacity directional arrow on gate cells
- subtle pre-finish treatment
- neutral shared Finish

This is close to the latest design direction, except the latest user preference is stricter: **only Home should receive a full player-color cell fill**; gate arrows are subtle; pre-finish should not look like another full player-color square.

---

## 2. Source issues Claude should resolve before cosmetic expansion

### P0 — Match-finish navigation bug in `MatchScreen`

`_animateMovement()` commits the final `GameState` and then calls `_afterMovement()`.

However, `_afterMovement()` only enters its main branch when phase is:

- `TurnPhase.turnFinished`, or
- `TurnPhase.animatingMove`

A winning engine transition has phase `TurnPhase.matchFinished`.

Therefore the current code can fail to navigate to `ResultScreen` after a normal animated winning move because `_afterMovement()` does nothing for an already-finished state.

Fix this presentation/orchestration bug without changing the engine's win rule.

Required behavior:
1. exact finish is reached;
2. movement animation completes;
3. final state becomes `matchFinished`;
4. winner celebration may play;
5. navigate once to `ResultScreen`.

### P0 — "REMATCH" is not a true rematch

`ResultScreen` currently handles REMATCH using `Navigator.pop()`.

Because the match/result flow uses replacement navigation, this does not reliably reconstruct the same match configuration as a fresh rematch.

A real rematch should create a new `GameState` with:
- same player/seat/kind configuration
- same Classic/Blitz rule profile
- each player reset to `ruleProfile.startProgress`
- active player reset according to the chosen match-start policy
- no winner
- no extra casts
- waiting-for-cast phase

Do not reuse stale winner/progress state.

### P1 — Persistence exists but is not wired into the product

`MatchStorage` exists and has tests, but no production source references it.

Current `HomeScreen` has no functional Continue Match integration.

Required eventual behavior:
- save stable match state at safe transition boundaries;
- offer Continue Match only if a valid unfinished save exists;
- resume that match;
- clear save when abandoned or completed if product policy says so.

Do not persist halfway through a visual animation.

### P1 — Application controllers exist but are unused

`PlayerController`, `HumanController`, and `BotController` are currently dead architecture.

`MatchScreen` directly:
- owns `FairBinaryCastGenerator`;
- schedules bot turns with `Future.delayed`;
- applies domain actions;
- manages movement animation;
- manages turn continuation;
- manages navigation.

This makes `MatchScreen` too responsible.

Do **not** perform a risky rewrite immediately. First protect behavior with tests. Then move non-visual orchestration into an application-level `MatchController`/`MatchCoordinator` while keeping:
- domain engine pure;
- animation presentation-only;
- UI widgets declarative.

### P1 — Dead/obsolete presentation widgets remain

The source contains older widgets that are no longer referenced:
- `cast_area_widget.dart`
- `player_card.dart`

Remove or clearly deprecate them after confirming no references. Dead duplicate UI will confuse future cosmetic work.

### P1 — Settings screen is a placeholder

`SettingsScreen` currently displays only "Settings (Not implemented for MVP)".

Do not spend time on a large settings system yet, but avoid presenting fake functionality. At minimum establish a real settings model later for:
- sound
- haptics
- animation speed
- selected cosmetic IDs

### P2 — Bottom navigation contains inactive affordances

The Home bottom navigation visually shows Home / Play / Profile, but no meaningful navigation behavior is implemented.

Either:
- implement real destinations, or
- simplify the navigation until those destinations exist.

Do not ship decorative buttons that appear interactive but do nothing.

### P2 — Route generator has a small escaped interpolation error

The final line prints:

`Successfully generated \${outFile.path}`

rather than evaluating the path.

This does not affect route generation output, but should be cleaned.

### P2 — Documentation/task state is stale

`task.md` still marks screens/dev tools/tests incomplete, while `walkthrough.md` claims the redesign is complete.

Claude should not trust these completion claims. Source + tests + actual debug rendering are the truth.

---

## 3. Architecture objective for the next phase

The next phase is **not to design more board images**.

The next phase is to establish an immutable visual geometry contract so that future:

- board skins
- profile frames
- piece skins
- TamTam cube/dice skins
- cast-tray skins

can be swapped without changing game coordinates or manually repositioning assets.

The rule is:

> Layout owns geometry. Skins only fill predefined slots.

Gameplay coordinates must never depend on image pixels.

---

## 4. Required Visual Layout Contract

### 4.1 Board asset contract

Every board skin uses a canonical **1080 × 1080** design canvas.

Within it:

- `boardCanvas`: 1080 × 1080
- `playableGridRect`: x=54, y=54, width=972, height=972
- 9×9 grid
- each cell = 108 × 108 design units

Canonical cell-center formula:

- column index A=0 ... I=8
- row index 1=0 ... 9=8

`centerX = 54 + (columnIndex + 0.5) * 108`
`centerY = 54 + (rowIndex + 0.5) * 108`

Examples:

- A1 = (108,108)
- E1 = (540,108)
- H1 = (864,108)
- E5 = (540,540)
- E9 = (540,972)
- I5 = (972,540)

Gameplay overlay coordinates derive from this formula, never from artwork.

### 4.2 Player frame position contract

Player frames are separate from board skin artwork.

Render frame size relative to displayed board size `B`:

- `frameSize = 0.16 * B`

Frame-center anchors relative to the board's top-left:

- Top: `(0.50B, -0.03B)`
- Right: `(1.03B, 0.50B)`
- Bottom: `(0.50B, 1.03B)`
- Left: `(-0.03B, 0.50B)`

This intentionally places the frame mostly outside the playable board and prevents it from covering normal cells.

For two-player mode:
- show Top and Bottom slots;
- hide Left and Right;
- allow the board to use more horizontal space.

For four-player mode:
- show all four;
- reduce board display size enough to keep side frames on-screen.

Do not change the board skin itself between 2P and 4P.

### 4.3 Profile frame asset contract

Every profile-frame skin uses a **512 × 512 transparent canvas**.

Suggested invariant safe zones:

- portrait/icon safe circle: center approximately `(256,210)`, diameter 300
- nameplate safe rect: x=80, y=360, width=352, height=90
- decorative frame may use the remaining canvas

Text such as "Player 1" is rendered by Flutter; never bake player names into art.

The frame skin may change, but its 512×512 canvas and safe zones do not.

### 4.4 Piece asset contract

Every piece skin uses a **512 × 512 transparent canvas**.

Displayed normal size:
- `0.68 × cellSize`

Stacked/coexisting safe-cell size:
- approximately `0.44 × cellSize`

The logical anchor is always the center of the current canonical cell.

A piece skin may not alter its logical anchor.

### 4.5 Gate overlay contract

Gate cells remain neutral.

Draw only a small player-color inward arrow programmatically:

- size: approximately `0.20 × cellSize`
- opacity: approximately `0.32–0.40`
- canonical direction comes from route geometry

No board skin may bake gate arrows into its art.

### 4.6 Home and Finish overlay contract

Home:
- full player-color fill may be drawn programmatically.

Finish E5:
- shared neutral finish treatment, never seat-colored.

Latest visual rule:
- do not make pre-finish cells look like full player-colored squares.

### 4.7 Cast tray asset contract

Every cast-tray skin uses a **1000 × 240 transparent design canvas**.

Display target:
- width ≈ `0.75 × displayedBoardSize`
- preserve 1000:240 aspect ratio

The active player's color is a **programmatic accent/border**, not a separate tray image per player.

The tray should expose four fixed cube slots.

### 4.8 TamTam cube/dice skin contract

Every cube skin uses a **512 × 512** square source canvas or equivalent procedural skin.

It remains a binary TamTam object:
- White face
- Black face

Never add numeric pips or convert it to a standard die.

Displayed cube size should be derived from the tray slot, not from the asset's native pixel size.

The casting probability remains domain-owned and completely independent of dice skin.

---

## 5. Skin architecture

Introduce presentation-only types similar to:

- `BoardSkin`
- `ProfileFrameSkin`
- `PieceSkin`
- `DiceSkin`
- `CastTraySkin`
- `TamTamSkinPack`
- `SkinCatalog`

Recommended source organization:

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

The domain layer must not import any of these.

---

## 6. Calibration screen before new artwork

Before implementing visually rich board/frame/dice assets, build a DEBUG-ONLY `VisualCalibrationScreen`.

It should render:

- board canvas bounds
- playable 9×9 grid bounds
- cell centers
- E1/I5/E9/A5 Homes
- H1/I8/B9/A2 gates
- E5 Finish
- all four player-frame rectangles
- piece-size bounding circle
- cast-tray rectangle
- four cube-slot rectangles

Use obvious temporary colors and labels.

The calibration screen is successful when the user can inspect it on the target phone and approve positions/scales.

Only after that approval should artistic skins be created.

---

## 7. Non-negotiable regression protection

Before layout refactoring:
- preserve canonical route JSON;
- preserve generated route parity tests;
- preserve movement/capture/cast tests;
- add presentation tests for board coordinate mapping;
- add a test that A1 renders top-left and I9 bottom-right;
- add tests for player-frame anchor placement if practical;
- add a test that piece coordinate is derived from the canonical route cell.

Do not "fix" route behavior by changing route arrays.

Outer route remains anti-clockwise.
After gate entry, the inward route follows the canonical clockwise inward path.

---

## 8. Do not build APKs

During this handoff phase:
- do not run `flutter build apk`;
- do not sign/install release builds;
- do not spend time on release packaging.

Allowed:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter run` for debug visual inspection if the local repository permits it.

The user will handle APK packaging later.

