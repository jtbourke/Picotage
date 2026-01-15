# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Picotage is a PICO-8 game cartridge based on Sabotage (1981, Apple II). It's a tower defense arcade game where the player defends a base from helicopters and paratroopers.

## Development Commands

**Run the game:** Open `carts/picotage.p8` in PICO-8 and press Ctrl+R or click Run.

**Export for web:** In PICO-8, run `export picotage.html` then move outputs to `docs/`.

## Architecture

The game is a single-file Lua cartridge (`carts/picotage.p8`, ~1,715 lines) organized into 6 sections marked with `-->8` tab comments:

1. **Main Logic** - Game state machine, `_init()`, `_update60()`, `_draw()`, UI rendering
2. **Utilities** - Helper functions, collision detection (`collide()`, `collidepixel()`), scoring
3. **Base/Tower** - Player base health/damage, turret aiming and rotation, powerup system
4. **Bullets** - Projectile physics, rendering, collision response
5. **Particles** - Visual effects (smoke, fire, blood, chaff)
6. **Helicopters & Soldiers** - Enemy spawning, AI behavior, elite troops with shields

**Game States:** `introducing` → `loading` → `playing` → `pausing` (game over/level complete)

**Key Callbacks:**
- `_init()` - Initializes cartdata, cheats, game variables
- `_update60()` - Main game loop at 60 FPS
- `_draw()` - Rendering

**Object Pattern:** Table-based objects with hitboxes:
```lua
base = {x=56, y=119, damage=0, hitbox={x=0,y=0,w=16,h=8}}
```

## PICO-8 Specifics

- Uses PICO-8 v0.2.6b APIs (`cartdata`, `dset`/`dget` for saves, `sfx`, `btn`/`btnp`, `spr`/`sspr`)
- No external dependencies - self-contained cartridge
- Web export in `docs/` (served via GitHub Pages)

## Testing

Manual gameplay testing in PICO-8 runtime. No automated test framework.
