# TamTam V2 — MVP Scope

**Document revision:** 2.1

## In scope

### Gameplay
- 5×5 canonical board
- 40-unit route
- 2/4/6/8/16 casting
- per-piece independent progress
- universal Home safety
- exact capture
- dynamic 2+ stack immunity
- mixed-player protected stacks
- one-piece-per-cast selection
- exact Finish
- finished/inactive C3 pieces
- capture-only extra cast

### Modes
- Classic 4/4
- Rapid 4/1
- Blitz 1/1

### Local configurations
Carry forward unless explicitly changed:
- 2 local humans
- 4 local humans
- 1 human vs 1 bot
- 1 human vs 3 bots

### Bot
- same legal engine
- same RNG
- safety-aware move scoring
- no cheating

### Presentation
- premium Home/setup/game/result
- 5×5 board
- stack rendering
- legal piece-selection affordance
- enlarged visual Finish overlay
- four Finish triangles
- cube animation
- cell-by-cell movement
- capture/stack feedback
- pause/rematch
- skins
- audio/haptics/game feel

## Out of scope unless reprioritized

- production online multiplayer
- ranked
- tournaments
- account backend
- server-authoritative rooms
- economy/gems
- marketplace
- achievements/daily rewards

## MVP Definition of Done

- canonical JSON routes pass tests
- all modes create correct piece counts
- all pieces have independent progress
- legal piece selection is enforced
- stack immunity works for same/mixed owners
- Home safety works for every player
- capture resets only captured piece
- finished pieces leave active occupancy
- Finish triangles reflect completed pieces
- bots select only legal moves
- board renders exact 5×5 logical geometry
- 5+ stack visuals keep 20% size and overlap
- rematch resets full V2 state
- regression tests pass
- manual device verification passes
