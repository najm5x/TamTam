# TamTam V2 — READ ME FIRST

**Ruleset:** V2  
**Document revision:** 2.1  
**Date:** 2026-08-29  
**Status:** Gameplay specification closed for implementation.

This folder is the authoritative TamTam V2 specification set.

V2 is a deliberate gameplay redesign of the previous 9×9 / one-piece implementation. Do not treat it as a visual-only board resize.

## Authority

When sources disagree:

1. Latest explicit user decision
2. `04_Canonical_Routes_V2.json`
3. `01_Game_Rules_Constitution_V2.md`
4. `TamTam_Project_Instructions_V2.md`
5. Current working source
6. V1 documentation, prompts, screenshots, artwork, or assumptions

## Canonical V2 summary

- Board: **5×5**, A1–E5
- Finish: **C3**
- Green Home/Entrance: **C1 / D1**
- Blue Home/Entrance: **E3 / E4**
- Yellow Home/Entrance: **C5 / B5**
- Red Home/Entrance: **A3 / A2**
- All four Home cells are safe for **any player**
- Cast values: **2, 4, 6, 8, 16**
- Four White = **8**
- Four Black = **16**
- Every piece travels **40 movement units**
- First round: **16**
- Second/final journey: **24**
- Classic: **4 pieces / finish all 4**
- Rapid: **4 pieces / finish 1**
- Blitz: **1 piece / finish 1**
- All active pieces start on Home; no unlock roll
- One cast moves exactly one piece
- Each piece has independent progress
- Normal-cell active occupancy of 2+ creates immunity regardless of ownership
- Any player may join an already immune stack without capture
- Capture resets only the captured piece
- Successful capture is the only source of an extra cast
- Exact Finish only; no over-move, under-move, or bounce
- If any piece has a legal move, the player must choose a legal piece
- If no piece can legally use the cast, no piece moves and the turn ends
- Finished pieces become inactive and are displayed only in their player's C3 triangle

## Board layout contract

- Source board canvas: **1080×1080 px**
- Resolution: **72 PPI**
- Margin: **50 px all sides**
- Logical game area: **980×980 px**
- Grid: **5×5**
- Logical cell size: **196×196 px**
- Pieces are centered in logical cells
- C3 remains a normal logical 196×196 cell
- Finish artwork may be visually enlarged as an overlay centered on C3 without changing grid geometry

Piece display in a normal occupied cell:

- 1 piece: 100%
- 2 pieces: 50% each
- 3 pieces: 33.33% each
- 4 pieces: 25% each
- 5 pieces: 20% each
- 5+ pieces: remain at 20% and overlap

## Migration rule

Before implementation:

- keep V1 recoverable in Git
- create/use a V2 migration branch
- audit V1 assumptions
- migrate domain/routes before presentation
- do not infer routes from artwork
- do not refactor unrelated systems

## Read order

1. `00_READ_ME_FIRST_V2.md`
2. `01_Game_Rules_Constitution_V2.md`
3. `02_Project_Description_V2.md`
4. `03_Canonical_Routes_V2.md`
5. `04_Canonical_Routes_V2.json`
6. `05_Technical_Architecture_V2.md`
7. `06_MVP_Scope_V2.md`
8. `07_Test_and_Verification_Plan_V2.md`
9. `09_Visual_Layout_Contract_V2.md`
10. `TamTam_Source_Audit_for_Claude_V2.md`
11. `TamTam_Claude_Master_Handoff_Prompt_V2.md`
12. `08_Gemini_Antigravity_Master_Prompt_V2.md`

There are no remaining known gameplay-rule blockers in this specification.
