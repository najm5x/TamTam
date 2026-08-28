# TamTam V2 — Project Description

**Document revision:** 2.1  
**Date:** 2026-08-29

TamTam is a premium Flutter mobile race-and-capture board game for Android and iOS.

V2 redesigns the physical board and expands piece strategy while preserving TamTam's core identity.

## V2 product identity

- compact 5×5 board
- four directional player identities
- shared central Finish
- binary White/Black casting
- cast values 2/4/6/8/16
- 40-unit journey per piece
- Classic, Rapid, and Blitz
- multi-piece strategic selection in Classic/Rapid
- dynamic mixed-player stack immunity
- exact landing capture
- capture-only extra casts
- safety-aware bots
- premium original presentation

## Modes

Classic:
- 4 pieces
- all 4 must finish

Rapid:
- 4 pieces
- first 1 to finish wins

Blitz:
- 1 piece
- first 1 to finish wins

All modes use the same route and journey length.

## Strategic character

Classic/Rapid support decisions such as:

- advance one lead piece
- develop several pieces
- create same-player immunity
- join mixed protected stacks
- leave a stack and intentionally expose or preserve remaining pieces
- capture vulnerable singles
- choose the safest legal piece for a cast

Home cells create fixed universal safe points, while 2+ occupancy creates temporary dynamic safe positions anywhere else.

## Finish presentation

C3 is logically one normal 5×5 cell.

Visually, the Finish can be enlarged and divided into four directional triangles.

Finished pieces become inactive domain objects and are shown in their player's triangle only.

## Architecture

One deterministic engine supports all modes through rule profiles.

Domain owns rules and state.

Presentation owns skins, visual stack layout, enlarged Finish overlay, animation, audio, and haptics.

## Current implementation objective

Migrate the existing V1 Flutter code to V2 in controlled phases:

1. V1 source audit
2. route/cast migration
3. per-piece domain state
4. mode profiles
5. occupancy/stack/capture
6. legal piece selection
7. bot policy
8. 5×5 presentation
9. V2 regression testing

Do not start with cosmetic board resizing before the engine knows the V2 rules.
