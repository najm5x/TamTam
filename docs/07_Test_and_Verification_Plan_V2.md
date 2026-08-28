# TamTam V2 — Test and Verification Plan

**Document revision:** 2.1

## Route tests

For each player verify:

- correct Home and Entrance
- first round exactly 16 moves and returns Home
- second journey exactly 24 moves
- Finish progress 40 = C3
- exact rotational equivalence
- orthogonal adjacency
- continuous crossing of progress 16
- correct inward turn after Entrance

## Casting tests

Verify:

- 3W1B = 2
- 2W2B = 4
- 1W3B = 6
- 4W = 8
- 4B = 16
- old value 32 is impossible
- generation uses four independent binary faces

## Mode tests

Classic:
- 4 pieces start at Home/progress 0
- win only after 4 finished

Rapid:
- 4 pieces start at Home/progress 0
- first finished piece wins

Blitz:
- 1 piece starts Home/progress 0
- first finish wins
- no progress-32 start

## One-cast / one-piece

Verify:

- one cast can move only one selected piece
- stack never moves as a group
- moving one piece does not mutate sibling piece progress

## Legal move selection

Example:

- cast 6
- Piece A at 38 => illegal overshoot
- Piece B at 20 => legal
- Piece B must be selectable/movable
- Piece A cannot be selected to waste the turn

If all unfinished pieces overshoot:

- no movement
- turn ends

No over-move, under-move, or bounce.

## Universal Home safety

For C1, E3, C5, A3:

- owner single piece safe
- opponent single piece safe
- mixed stack safe
- exact opponent landing on a single piece at Home does not capture

## Stack immunity

Verify:

- 1 normal-cell active piece vulnerable
- 2+ active pieces immune regardless of ownership
- opponent may join an existing protected stack
- joining causes no capture
- occupancy 3 -> 2 remains immune
- occupancy 2 -> 1 becomes vulnerable
- >4 total occupancy is supported
- 5+ does not imply gameplay cap

## Capture

Verify:

- exact landing on one vulnerable opponent captures
- passing over does not capture
- protected stack cannot be captured
- captured piece only resets
- victim's other pieces retain progress
- capture grants exactly one extra cast
- capture chains work

## Finish

Verify:

- exact progress 40 finishes
- piece status becomes finished/inactive
- piece is removed from active occupancy
- finished piece cannot move/capture/be captured
- finished piece does not contribute to stack immunity
- correct player's Finish triangle count increments
- Classic wins at 4
- Rapid/Blitz win at 1

## Bot

Verify bot:

- uses legal candidates only
- never selects overshoot when a legal candidate exists
- recognizes universal Home safety
- recognizes 2+ immunity
- never treats protected stack as capturable
- can create/join stacks
- considers exposure caused by leaving a stack
- prefers immediate win when available
- uses same cast RNG

## Board visual contract

Verify:

- canvas source contract 1080×1080
- 50 px margin
- 980×980 game area
- 5×5
- 196×196 cells
- C3 logical center at 540,540
- enlarged Finish overlay does not alter cell centers

## Piece presentation

For normal active occupancy:

- 1 = 100%
- 2 = 50%
- 3 ≈ 33.33%
- 4 = 25%
- 5 = 20%
- 6+ remains 20% and overlaps

Visual overlap must not alter domain occupancy.

## Regression source search

Inspect V1 assumptions:

- 9×9
- 81 cells
- 110
- 78
- Blitz start 32
- 4 Black -> 32
- 4 White -> 16
- E5 Finish
- old Home/Entrance coordinates
- one-piece-only player state
- single occupant per cell

## Manual matrix

At minimum:

- 2P Classic / Rapid / Blitz
- 4P Classic / Rapid / Blitz
- 1v1 bot all modes
- 1v3 bots all modes

Manually exercise stack creation, mixed joining, stack breaking, Home safety, capture, finish, overshoot, rematch, navigation, and skin alignment.
