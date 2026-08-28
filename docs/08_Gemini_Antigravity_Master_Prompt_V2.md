# TamTam V2 — Gemini Antigravity Master Prompt

You are working on the TamTam Flutter project. Migrate the existing V1 implementation to the approved V2 rules. Stay implementation-focused and do not dilute the task with unrelated exploration.

## Read first

1. `00_READ_ME_FIRST_V2.md`
2. `01_Game_Rules_Constitution_V2.md`
3. `03_Canonical_Routes_V2.md`
4. `04_Canonical_Routes_V2.json`
5. `05_Technical_Architecture_V2.md`
6. `09_Visual_Layout_Contract_V2.md`
7. `07_Test_and_Verification_Plan_V2.md`
8. `TamTam_Source_Audit_for_Claude_V2.md`

## Source priority

1. latest user decision
2. canonical V2 JSON
3. V2 Rules Constitution
4. V2 Project Instructions
5. current source
6. V1 material

## Non-negotiable V2 rules

- 5×5 A1–E5
- C3 Finish
- Green C1/D1; Blue E3/E4; Yellow C5/B5; Red A3/A2
- all four Homes safe for anyone
- cast values 2/4/6/8/16
- 4W=8; 4B=16
- four independent binary faces
- every piece progress 0→40
- first round 16; second journey 24
- Classic 4/4, Rapid 4/1, Blitz 1/1
- no unlock roll
- each piece independent
- one cast moves exactly one piece
- legal piece must be used if any exists
- no legal piece => no move, turn ends
- occupancy 2+ active pieces => immunity regardless of owner
- protected stack may be joined by anyone without capture
- capture only one vulnerable opponent on exact landing
- captured piece only resets
- capture only source of extra cast
- exact Finish
- finished piece becomes inactive and leaves active occupancy
- finished piece displayed only in player's Finish triangle

## Board visual contract

- source canvas 1080×1080
- 50 px margins
- game area 980×980
- cells 196×196
- piece centered in logical cell
- 1=100%, 2=50%, 3=33.33%, 4=25%, 5=20%
- 5+ remains 20% and overlaps
- C3 logical geometry stays uniform
- enlarged Finish is visual overlay only

## Migration order

1. Audit V1 assumptions.
2. Write/update canonical route and cast tests.
3. Migrate route/cast domain.
4. Add per-piece state.
5. Add mode profiles.
6. Implement legal piece candidate/selection.
7. Implement occupancy, universal Home safety, stacks, capture.
8. Implement finished/inactive state and win counts.
9. Upgrade bot using shared legal move generator.
10. Convert presentation to 5×5 / stacks / Finish triangles.
11. Run focused tests, then broader analyze/test as relevant.

## Constraints

- minimal targeted edits
- no unrelated refactor
- preserve existing interaction lock and working navigation unless V2 requires change
- no artwork-derived route geometry
- no browser automation
- no Chrome
- no emulator unless requested
- no adb unless requested
- no APK/AAB unless requested
- user normally runs manually

## Completion report

Keep concise:
- files changed
- V2 systems implemented
- tests/analyzer
- any contradiction/blocker
- confirmation unrelated systems were not refactored
