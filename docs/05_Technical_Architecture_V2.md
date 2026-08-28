# TamTam V2 — Technical Architecture

**Document revision:** 2.1

## Core principle

> One deterministic TamTam engine, many rule profiles and presentation layers.

V2 justifies targeted domain changes. It does not justify unrelated refactoring.

## Required domain concepts

### Rule profile

- Classic: `piecesPerPlayer=4`, `piecesRequiredToWin=4`
- Rapid: `piecesPerPlayer=4`, `piecesRequiredToWin=1`
- Blitz: `piecesPerPlayer=1`, `piecesRequiredToWin=1`
- start progress 0
- Finish progress 40

### Piece state

Every physical piece requires independent state:

- piece ID
- owner/player ID
- progress
- status: active or finished
- current cell derived from canonical route while active

Do not keep one shared player progress value.

### Player state

Owns player identity plus a collection of piece states.

Finished count is derived from finished pieces.

### Occupancy

Derive active board occupancy from piece state:

`Map<Cell, List<PieceRef>>`

Do not assume one occupant per cell.

Finished pieces are excluded from ordinary occupancy.

### Safety

A cell is safe when either:

1. it is one of the four universal Home cells; or
2. it contains 2+ active pieces.

Home safety applies regardless of ownership.

### Legal move generation

For a cast value, compute candidate moves for every unfinished piece.

A candidate is legal only if the full cast ends at progress <= 40.

If one or more legal candidates exist, exactly one must be selected.

If none exist, no move occurs and the turn ends.

### Move result

The engine should return enough deterministic information for UI animation:

- selected piece
- start progress/cell
- cast
- destination progress/cell
- intermediate canonical path
- capture, if any
- occupancy changes
- finished status
- winner status
- extra-cast status

Presentation must not become gameplay truth.

### Capture

Before mover arrival:

- universal Home destination => no capture
- exactly one vulnerable opponent active piece => capture it
- occupancy >=2 => no capture; join
- own single/multiple => join

Capture resets only the captured piece and grants exactly one extra cast.

### Finish

At progress 40:

- mark piece finished/inactive
- remove it from ordinary active occupancy
- derive/increment finished count
- display it in Finish triangle through presentation
- do not apply capture/stack rules to finished pieces

## Bot

The bot uses the same legal candidate moves as a human.

Score candidates with safety-aware heuristics; keep heuristic weights outside canonical rules.

## Presentation contract

Logical board:
- 5×5
- game area 980×980
- 196×196 logical cells
- origin at 50,50 on a 1080×1080 board canvas

C3 remains a normal logical cell.

An enlarged Finish is a visual overlay anchored to C3.

### Active stack rendering

- 1: 100%
- 2: 50%
- 3: 33.33%
- 4: 25%
- 5: 20%
- 5+: 20%, overlapping extras

Rendering must preserve exact logical occupancy even if visuals overlap.

### Finished pieces

Render completed pieces in four C3 visual triangles:

- Green top
- Blue right
- Yellow bottom
- Red left

Each player can contribute at most 4 finished pieces in Classic/Rapid.

These displayed pieces are not board occupancy.

## V1 migration hazards

Audit for:

- 9×9 / 81 cells
- old E5 Finish
- old Homes/Entrances
- 110/78/32 route assumptions
- Blitz start at 32
- old four-white=16 and four-black=32 mapping
- one piece per player
- shared progress per player
- one occupant per cell
- Classic win after one piece
- hard-coded 9×9 rendering math

## Coding constraints

- minimal targeted changes
- no unrelated refactor
- no Chrome/browser automation
- no emulator unless explicitly requested
- no adb unless explicitly requested
- no APK/AAB unless explicitly requested
- `flutter analyze` / `flutter test` allowed
- user normally runs the app manually
