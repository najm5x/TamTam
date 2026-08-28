# TamTam V2 — Game Rules Constitution

**Document revision:** 2.1  
**Date:** 2026-08-29  
**Status:** Authoritative and implementation-ready.

## 1. Board

TamTam V2 uses a strict **5×5 physical board**.

- Columns A–E, left to right
- Rows 1–5, top to bottom
- Finish: **C3**
- Never vertically flip the board

| Player | Seat | Home | Entrance |
|---|---|---|---|
| Green | Top | C1 | D1 |
| Blue | Right | E3 | E4 |
| Yellow | Bottom | C5 | B5 |
| Red | Left | A3 | A2 |

### Universal Home safety

All four Home cells are safe for **any player**.

A piece cannot be captured while it occupies C1, E3, C5, or A3, regardless of ownership or stack size.

Home safety is intrinsic and does not require a 2+ stack.

## 2. Modes and pieces

| Mode | Pieces per player | Pieces required to win |
|---|---:|---:|
| Classic | 4 | 4 |
| Rapid | 4 | 1 |
| Blitz | 1 | 1 |

All active pieces begin on the player's Home at progress 0.

There is no unlock roll.

Each piece has independent progress and identity.

One cast moves exactly **one** selected unfinished piece. A stack never moves as a unit.

## 3. Casting

TamTam uses four independent binary White/Black casting objects.

| Faces | Movement |
|---|---:|
| 3 White + 1 Black | 2 |
| 2 White + 2 Black | 4 |
| 1 White + 3 Black | 6 |
| 4 White | 8 |
| 4 Black | 16 |

Possible movement values: **2, 4, 6, 8, 16**.

Generate four independent binary faces and derive the value. Never choose uniformly from the five movement values.

## 4. Journey

Every piece in every mode:

- starts at progress 0
- first round = 16 movement units
- second/final journey = 24 movement units
- Finish = progress 40

Blitz uses the same 40-unit route as Classic and Rapid.

## 5. Direction

Outer route movement is anti-clockwise.

On the second/final journey, the piece reaches its player Entrance and then turns inward clockwise toward C3.

Follow canonical route indexes exactly.

## 6. Continuous movement

Movement does not stop at intermediate route boundaries.

If a cast crosses progress 16, continue immediately into the second journey using the remainder.

If a cast crosses the Entrance, turn inward and continue using the remainder.

No movement remainder is discarded.

## 7. Legal piece selection

After a cast:

- determine which unfinished pieces can use the exact cast without exceeding progress 40
- if at least one legal piece exists, the player must select one legal piece
- a player may not deliberately select an overshooting piece to waste the turn
- if no unfinished piece can legally use the cast, no piece moves and the turn ends

There are no over-moves or under-moves.

A cast always applies in full to exactly one piece.

## 8. Stacking and immunity

For ordinary active-board cells:

- 0 active pieces: empty
- 1 active piece: vulnerable unless the cell is a universally safe Home
- 2+ active pieces: immune stack

Immunity is based on total active occupancy, regardless of ownership.

Any player may land on an already immune 2+ stack.

When doing so:

- no capture occurs
- the arriving piece joins the stack
- all active pieces there remain immune

When pieces leave and occupancy returns to exactly one, normal vulnerability returns unless the cell is a safe Home.

## 9. Capture

Capture happens only when a moving piece lands exactly on **one vulnerable opponent active piece**.

Passing over pieces never captures.

Landing on an immune 2+ stack never captures.

On capture:

1. only the captured piece resets
2. it returns to its owner's Home
3. its progress returns to 0
4. all other pieces retain their state
5. the capturing player receives exactly one extra cast

Capture chains are allowed.

## 10. Extra cast

Successful capture is the only source of an extra cast.

No extra cast for cast value, round completion, Entrance, stacking, Home, or Finish events.

## 11. Finish

A piece finishes only by exact landing at progress 40 / C3.

If the cast would make the selected piece exceed 40, that piece is not a legal choice.

No bounce-back.

When a piece finishes:

- its status becomes finished/inactive
- it is removed from active board occupancy
- it cannot move
- it cannot capture
- it cannot be captured
- it does not contribute to stack immunity
- presentation displays it in that player's Finish triangle inside the C3 visual

Finish triangle mapping:

- Green: top triangle
- Blue: right triangle
- Yellow: bottom triangle
- Red: left triangle

The Finish visual may be larger than the logical C3 cell, but logical C3 remains part of a uniform 5×5 grid.

## 12. Win conditions

Classic: first player with all 4 pieces finished wins.

Rapid: first player with any 1 of their 4 pieces finished wins immediately.

Blitz: first player to finish their single piece wins immediately.

## 13. Bot

The bot uses the same cast generator, legal move generator, route data, occupancy rules, and engine as humans.

No cheating.

The bot should score legal piece moves using a safety-aware strategy, including:

- immediate win
- finishing a piece
- capture
- creating/joining immunity
- preserving useful immunity
- avoiding unnecessary exposure
- switching pieces when continuing one becomes vulnerable
- progress toward Finish

The bot tends to continue a piece while safe, then considers another piece when continued advancement becomes vulnerable.

## 14. Presentation independence

Gameplay geometry is programmatic.

Artwork never determines board coordinates, Homes, Entrances, Finish, routes, progress, occupancy, immunity, or capture.

Piece sizing, overlap, enlarged Finish art, skin selection, animation, audio, and haptics are presentation only.
