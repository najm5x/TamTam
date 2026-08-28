# TamTam Project Instructions — V2

## Authority

1. Latest explicit user decision
2. `04_Canonical_Routes_V2.json`
3. `01_Game_Rules_Constitution_V2.md`
4. This file
5. Current Flutter source
6. V1 material

## V2 canonical rules

- 5×5 A1–E5
- Finish C3
- Green C1 / D1
- Blue E3 / E4
- Yellow C5 / B5
- Red A3 / A2
- all Homes universally safe
- casts 2/4/6/8/16
- 4 White = 8
- 4 Black = 16
- journey 16 + 24 = 40
- Classic 4 pieces / finish 4
- Rapid 4 / finish 1
- Blitz 1 / finish 1
- all pieces start Home
- no unlock roll
- one cast moves one piece
- independent piece progress
- must use a legal piece if one exists
- no legal piece => no move, turn ends
- normal active occupancy 2+ => immune regardless of ownership
- protected stacks may be joined by opponents without capture
- Home safety applies regardless of ownership
- exact single-vulnerable-piece capture
- captured piece only resets
- capture-only extra cast
- finished piece becomes inactive and moves to player Finish-triangle presentation
- finished pieces do not participate in occupancy, capture, or immunity
- exact Finish only; no over/under/bounce

## Visual layout

- board canvas 1080×1080
- 72 PPI metadata
- 50 px margins
- 980×980 logical game area
- 196×196 cells
- pieces centered on logical cells
- 1/2/3/4/5 occupancy scales to 100/50/33.33/25/20%
- 5+ remains 20% and overlaps
- enlarged Finish is visual overlay only

## Architecture

One deterministic engine, multiple rule profiles.

Domain must remain independent from:

- widgets
- artwork
- skins
- animation
- audio
- persistence implementation
- networking

V2 requires targeted domain migration because product rules changed. Do not refactor unrelated systems.

## Coding rules

- inspect only relevant files
- make minimal targeted changes
- no unrelated refactor
- routes remain programmatic
- artwork never gameplay truth
- do not install extensions/plugins
- no browser automation
- no Chrome
- no emulator unless explicitly requested
- no adb unless explicitly requested
- no APK/AAB unless explicitly requested
- `flutter analyze` / `flutter test` allowed
- user normally runs the app manually
