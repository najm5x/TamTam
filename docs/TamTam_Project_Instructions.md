# TamTam Project Instructions

## Purpose

This document governs how ChatGPT and coding/design agents should work on the TamTam mobile board-game project.

TamTam V2 is the current authoritative ruleset.

Do not use obsolete V1 gameplay assumptions when they conflict with V2.

---

## 1. Source-of-Truth Priority

When sources disagree, use this order:

1. Latest explicit user decision
2. `04_Canonical_Routes_V2.json`
3. `01_Game_Rules_Constitution_V2.md`
4. This `TamTam_Project_Instructions.md`
5. Current working Flutter source
6. Older V1 documents, prompts, screenshots, plans, or artwork

Never preserve an old rule merely because it exists in code.

Never infer gameplay rules or geometry from artwork.

---

## 2. Core Working Principle

TamTam uses:

> One deterministic gameplay engine, multiple rule profiles, and separate presentation layers.

Keep gameplay/domain logic separate from:

- Flutter widgets
- board artwork
- skins
- animation
- audio
- haptics
- persistence implementation
- networking

The engine remains the gameplay authority.

Presentation may visualize gameplay state, but must not define it.

---

## 3. TamTam V2 Authority

The detailed V2 gameplay rules are defined in:

- `01_Game_Rules_Constitution_V2.md`
- `03_Canonical_Routes_V2.md`
- `04_Canonical_Routes_V2.json`
- `09_Visual_Layout_Contract_V2.md`

Use those files automatically.

Do not ask the user to repeat settled rules.

### V2 high-level identity

TamTam V2 uses:

- 5×5 board, A1–E5
- shared Finish at C3
- Green Home C1 / Entrance D1
- Blue Home E3 / Entrance E4
- Yellow Home C5 / Entrance B5
- Red Home A3 / Entrance A2
- universal Home safety for any player
- cast values 2, 4, 6, 8, 16
- 40 movement units per piece
- first round 16
- second/final journey 24
- Classic: 4 pieces, finish all 4
- Rapid: 4 pieces, finish 1
- Blitz: 1 piece, finish 1
- no unlock roll
- one cast moves exactly one piece
- independent progress per piece
- exact Finish only
- capture only on exact landing on one vulnerable opponent piece
- capture resets only the captured piece
- successful capture is the only source of an extra cast
- normal-cell occupancy of 2+ active pieces gives immunity regardless of ownership
- protected stacks may be joined by any player without capture
- finished pieces become inactive and are displayed in the player's Finish triangle

Do not silently change any of these rules.

---

## 4. Canonical Route Rules

Treat `04_Canonical_Routes_V2.json` as the canonical machine-readable route source.

Do not:

- recreate routes from screenshots
- derive coordinates from board pixels
- infer paths from artwork
- substitute approximate routes
- revive V1 9×9 route logic

Other player routes must remain exact rotations of the approved canonical pattern.

---

## 5. Gameplay Migration Policy

The original V1 engine was previously considered frozen during visual work.

V2 is now an explicit product-rule change and therefore allows targeted domain changes required for the migration.

However:

- change only what V2 requires
- do not refactor unrelated gameplay systems
- preserve known-working orchestration where compatible
- preserve rollback through Git
- migrate routes/domain before presentation
- validate gameplay before visual polish

Do not treat the V2 migration as permission for a broad rewrite.

---

## 6. Visual Direction

TamTam must feel like a premium mobile game, not a generic Flutter or business application.

Maintain one coherent TamTam visual universe.

Artwork must never determine gameplay geometry.

Layout owns geometry. Skins fill fixed visual slots.

### V2 board visual contract

Use `09_Visual_Layout_Contract_V2.md` as authority.

Key layout values:

- board canvas: 1080×1080 px
- margin: 50 px on all sides
- logical game area: 980×980 px
- grid: 5×5
- logical cell size: 196×196 px
- pieces centered on logical cells
- enlarged Finish presentation is visual only and must not distort the logical grid

For active pieces sharing a cell:

- 1 piece: 100%
- 2 pieces: 50%
- 3 pieces: 33.33%
- 4 pieces: 25%
- 5 pieces: 20%
- 5+ pieces: remain 20% and overlap

Finished pieces are presentation-only inside the four Finish triangles and do not participate in active board occupancy.

---

## 7. Coding Work Rules

For coding tasks:

- inspect only relevant files
- prefer minimal targeted changes
- do not refactor unrelated systems
- do not install extensions
- do not install IDE plugins
- do not use browser automation
- do not launch Chrome
- do not run emulator unless explicitly requested
- do not use adb unless explicitly requested
- do not build APK/AAB unless explicitly requested
- `flutter analyze` and `flutter test` are allowed when relevant
- the user normally runs the app manually

Do not make cosmetic work modify domain behavior.

Do not make gameplay work depend on visual assets.

---

## 8. Coding-Agent Workflow

For implementation tasks:

1. identify the exact layer
2. read the relevant V2 authority files
3. inspect only relevant source files
4. make the smallest required change
5. run focused tests
6. run broader analyzer/tests only when relevant
7. let the user manually run the app
8. review the result
9. iterate
10. record new authoritative decisions in TamTam HQ

Avoid large mixed tasks combining:

- engine
- UI
- persistence
- networking
- assets
- unrelated refactors

Prefer focused phases.

---

## 9. V2 Implementation Order

Unless the user explicitly changes priority, use this migration sequence:

1. source audit for obsolete V1 assumptions
2. canonical route migration
3. cast-value migration
4. per-piece domain state
5. Classic/Rapid/Blitz rule profiles
6. legal piece-selection logic
7. occupancy, stack immunity, Home safety, and capture
8. finished-piece state and win conditions
9. bot strategy
10. 5×5 presentation and multi-piece rendering
11. full V2 regression testing
12. manual gameplay verification

Do not begin by merely resizing the board widget.

---

## 10. Bot Rules

Bots must use:

- the same engine as humans
- the same casting probabilities
- the same legal move generator
- the same routes
- the same stacking/capture/safety rules

No cheating.

Bot strategy should be safety-aware rather than rigid.

It may consider:

- immediate win
- finishing a piece
- capture
- creating or joining immunity
- preserving immunity
- avoiding unnecessary vulnerability
- switching pieces when continuing one becomes unsafe
- progress toward Finish

Bot heuristics are implementation policy, not separate gameplay rules.

---

## 11. Testing and Regression

Use `07_Test_and_Verification_Plan_V2.md` for formal V2 verification.

Pay special attention to regressions involving:

- V1 9×9 assumptions
- old Finish E5
- old route lengths 110/78
- Blitz start progress 32
- old 4 White = 16
- old 4 Black = 32
- one-piece-per-player assumptions
- one occupant per cell assumptions
- Classic win after one piece
- capture resetting more than one piece

Challenge contradictions instead of preserving them.

---

## 12. Product Scope

Use `06_MVP_Scope_V2.md` for MVP boundaries.

Do not overbuild future systems during MVP work unless explicitly reprioritized.

Deferred systems may include:

- production online multiplayer
- matchmaking
- ranked play
- tournaments
- accounts/backend
- server-authoritative networking
- progression/economy
- achievements
- monetization expansion

Future-safe architecture is good.

Premature implementation is not.

---

## 13. Asset and Skin Rules

Skins are presentation-only.

Do not let skins alter:

- coordinates
- routes
- movement timing
- Home
- Entrance
- Finish
- capture
- stack immunity

Text should generally remain Flutter-rendered rather than baked into reusable assets unless explicitly requested.

Keep artwork original to TamTam.

Do not copy proprietary artwork or branding from Ludo or other games.

---

## 14. HQ Behavior

When discussing TamTam:

- use V2 rules automatically
- do not revive V1 assumptions
- do not ask the user to repeat settled decisions
- call out contradictions and regressions
- distinguish gameplay logic from presentation
- keep high-level decisions in TamTam HQ
- keep detailed implementation in specialist chats unless specifically requested
- prefer practical implementation-focused responses
- preserve the working project whenever possible
- treat explicit new user decisions as authoritative immediately

---

## 15. Current Project Principle

Prioritize:

1. gameplay correctness
2. canonical route correctness
3. multi-piece state correctness
4. stack/capture/safety correctness
5. responsiveness and clarity
6. premium game feel
7. extensibility
8. cosmetics

Never trade gameplay correctness for visual appearance.
