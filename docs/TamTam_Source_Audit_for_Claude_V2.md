# TamTam V2 — Source Audit for Claude

Audit before implementation. Do not start with a broad refactor.

## Find V1 assumptions

### Board
- 9×9
- 81 cells
- A–I
- old E5 Finish
- old Homes and Entrances
- hard-coded 9-grid layout math

### Journey
- 110
- 78
- Blitz progress 32
- V1 round boundary constants

### Casting
Find:
- 4 White -> 16
- 4 Black -> 32

Target:
- 4 White -> 8
- 4 Black -> 16

### Piece model
Find:
- one progress per player
- one token per player
- no piece IDs
- capture resetting whole player
- Classic winner after one piece

### Occupancy
Find:
- one occupant per cell
- single piece lookup per cell
- capture code that cannot represent lists of pieces
- UI assuming max one piece per cell

### Turn orchestration
Find:
- cast -> automatic single-piece move
- lack of legal-candidate selection
- rapid-cast interaction lock; preserve it
- capture extra-cast lifecycle
- bot entry points
- rematch reset

### Safety
Target:
- all four Homes safe for any owner
- normal 2+ active occupancy immune

### Finish
Target:
- finished/inactive state
- remove from active occupancy
- presentation triangle only

### UI
Known likely files:
- `lib/presentation/layout/visual_layout_contract.dart`
- `lib/presentation/screens/match_screen.dart`
- `lib/presentation/screens/match_setup_screen.dart`
- `lib/presentation/screens/result_screen.dart`
- `lib/presentation/widgets/board_widget.dart`
- `lib/presentation/widgets/board_cell_view.dart`
- `lib/presentation/widgets/player_hud.dart`
- `lib/presentation/widgets/cast_tray.dart`
- `lib/presentation/widgets/tamtam_cube.dart`
- skin files

Find:
- 9×9 sizing
- one-piece rendering
- no piece-selection affordance
- old cast values
- no Rapid mode
- old result assumptions

### Tests
Classify:
- retain
- rewrite for V2
- obsolete V1

## Audit output

Return:

| Layer | File/symbol | V1 assumption | Required V2 change | Risk |
|---|---|---|---|---|

Then provide:

- minimum migration file set
- first tests to write
- files not worth touching
- any unexpected contradiction with V2 docs

Do not invent gameplay rules. The V2 spec is closed.
