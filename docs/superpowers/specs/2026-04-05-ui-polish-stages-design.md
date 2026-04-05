# Fighting Game Upgrade: UI, Visual Polish & Stages

## Overview
Upgrade the Street Fighter Clone with new characters (PixelLab), improved menu flow (Character Select, Options, Stage Select), visual polish (particles, screen shake, slowmo), and announcer voice lines (ElevenLabs).

## 1. New Characters (PixelLab)

### Character Roster (3 total)
| ID | Name | Description | Style Reference |
|----|------|-------------|-----------------|
| `fighter_01` | **Current Fighter** | Blonder Fighter, blaues Outfit | Already exists as p1/p2 |
| `fighter_02` | **Ryu-Type** | Dark-haired martial artist, white gi, red headband, muscular build | Goku x Ryu |
| `fighter_03` | **Villain** | Muscular villain, purple energy aura, cape/armor, scar across face | Frieza x M.Bison |

### Sprite Requirements per Character
- Size: 92px height, side-view perspective
- 13 animation sheets (horizontal strips, frame_width = 92px):
  - idle, walk, jump, crouch
  - stand_lp, stand_hp, stand_lk, stand_hk
  - crouch_hk, fireball, dragon_punch
  - hit_stun, ko

### Asset Structure
```
assets/
  fighters/
    fighter_01/sheets/   (move existing p1 assets here)
    fighter_02/sheets/   (new Ryu-type)
    fighter_03/sheets/   (new Villain)
```

### SpriteLoader Changes
- Refactor from hardcoded p1/p2 to dynamic loading by fighter ID
- `load_fighter_frames(fighter_id: String) -> SpriteFrames`
- Fighter selection passed from character select to game scene

## 2. Menu Flow

### Scene Flow
```
main.tscn (Main Menu)
  → character_select.tscn (Character Select)
    → stage_select.tscn (Stage Select)
      → game.tscn (Fight)
        → main.tscn (after match end)

main.tscn → options.tscn (Options) → main.tscn
```

### Main Menu (update existing)
- Buttons: FIGHT! → goes to Character Select, OPTIONS, QUIT
- Title styling upgrade with larger font

### Character Select Screen (`scenes/ui/character_select.tscn`)
- Split layout: P1 selects left side, P2 selects right side
- Bottom: Character portrait grid (3 fighters as clickable panels)
- Center: Preview sprite (animated idle) for each player's selection
- P1 controls: A/D to navigate, U to confirm
- P2 controls: Left/Right arrows or gamepad to navigate, confirm button
- AI toggle for P2 (default: AI on)
- "READY" confirmation per player, then auto-transition to Stage Select
- Script: `scripts/ui/character_select.gd`

### Stage Select Screen (`scenes/ui/stage_select.tscn`)
- Horizontal stage preview cards (3 stages)
- P1 selects stage (or random)
- Arrow keys / A/D to browse, confirm to select
- Script: `scripts/ui/stage_select.gd`

### Options Screen (`scenes/ui/options.tscn`)
- SFX Volume slider (0-100)
- Music Volume slider (0-100, for future use)
- Round count: 1 / 2 / 3 (default 2)
- Timer length: 60 / 99 / Infinite
- Back button → Main Menu
- Settings stored in GameSettings autoload
- Script: `scripts/ui/options.gd`

### GameSettings Autoload (`scripts/game_settings.gd`)
```gdscript
var p1_fighter: String = "fighter_01"
var p2_fighter: String = "fighter_01"
var stage_id: String = "dojo"
var p2_is_ai: bool = true
var rounds_to_win: int = 2
var round_timer: int = 99
var sfx_volume: float = 1.0
var music_volume: float = 1.0
```

## 3. Stage Selection

### Stages (3 total)
| ID | Name | Description | PixelLab Prompt |
|----|------|-------------|-----------------|
| `dojo` | **Dojo** | Traditional Japanese dojo, wooden floor, paper walls, hanging lanterns, warm lighting | Side-view pixel art Japanese dojo interior |
| `rooftop` | **Rooftop** | Night city rooftop, neon skyline, cyberpunk aesthetic, rain | Side-view pixel art cyberpunk rooftop at night |
| `temple` | **Temple** | Ancient stone temple, clouds, mystical energy, pillars | Side-view pixel art ancient stone temple with clouds |

### Stage Asset Structure
```
assets/stages/
  dojo/background.png
  rooftop/background.png
  temple/background.png
```

### Stage Scene Changes
- `stage.tscn` updated to accept a background texture parameter
- Background loaded dynamically based on `GameSettings.stage_id`
- Floor/walls remain the same (collision geometry unchanged)

## 4. Visual Polish

### Screen Shake
- Add `Camera2D` to game scene (currently no camera)
- Shake on: heavy attacks (small), special moves (medium), KO (large)
- Implementation: random offset + rotation decay over ~0.3s
- Shake intensity levels: small=3px, medium=6px, large=10px

### Hit Effects (GPUParticles2D)
- **Hit Sparks**: White/yellow burst on normal hit contact
  - 12-16 particles, spread 45°, lifetime 0.2s
  - Spawned at hitbox collision point
- **Block Sparks**: Blue/cyan burst on block
  - 8 particles, smaller, lifetime 0.15s
- **Heavy Hit**: Larger orange/red burst for HP/HK
  - 20 particles, spread 60°, lifetime 0.3s

### KO Effects
- **Screen Flash**: White ColorRect flash (0.1s) on KO
- **Slowmo**: `Engine.time_scale = 0.3` for 0.5s real-time, then restore
- **Impact Freeze**: 3-frame pause (hitlag) on heavy attacks

### Fireball Trail
- GPUParticles2D attached to projectile scene
- Color matches character energy (blue for fighter_01, orange for fighter_02, purple for fighter_03)
- 6-8 particles trailing behind, fading out

### VFX Manager (`scripts/vfx_manager.gd` - Autoload)
```gdscript
func spawn_hit_spark(pos: Vector2, type: String)  # "light", "heavy", "block"
func screen_shake(intensity: float, duration: float)
func screen_flash(color: Color, duration: float)
func slowmo(time_scale: float, duration: float)
func hitlag(frames: int)
```

## 5. Sound Upgrade (ElevenLabs)

### Announcer Voice Lines
Generate with ElevenLabs TTS, deep dramatic male voice:
- "ROUND 1", "ROUND 2", "ROUND 3"
- "FIGHT!"
- "K.O.!"
- "PLAYER 1 WINS!", "PLAYER 2 WINS!"
- "PERFECT!" (if winner has full health)
- "TIME OVER!"
- "SELECT YOUR FIGHTER!"
- "CHOOSE YOUR STAGE!"

### New SFX (ElevenLabs Sound Effects)
- Heavy impact hit (more bass, DBZ-style)
- Energy charge (for fireball startup)
- Dragon punch whoosh (rising attack)

### AudioManager Updates
- Replace existing placeholder sounds where announcer versions are better
- Add new sound entries for announcer lines
- Volume control integration with GameSettings

## 6. Data Flow

### Character Select → Game
GameSettings autoload carries selections:
1. Player selects fighter → `GameSettings.p1_fighter = "fighter_02"`
2. Player selects stage → `GameSettings.stage_id = "rooftop"`
3. Game scene reads settings on `_ready()`:
   - Loads correct sprite frames per fighter
   - Loads correct stage background
   - Applies round/timer settings

### Fighter Loading
- `SpriteLoader` refactored to load any fighter by ID
- Fighter scene reads `GameSettings` to determine which sprites to use
- `fighter.gd` gets new `fighter_id` export var

## 7. Files to Create
- `scripts/game_settings.gd` (autoload)
- `scripts/vfx_manager.gd` (autoload)
- `scripts/ui/character_select.gd`
- `scripts/ui/stage_select.gd`
- `scripts/ui/options.gd`
- `scenes/ui/character_select.tscn`
- `scenes/ui/stage_select.tscn`
- `scenes/ui/options.tscn`

## 8. Files to Modify
- `scripts/sprite_loader.gd` - dynamic fighter loading
- `scripts/fighter.gd` - fighter_id support
- `scripts/game_manager.gd` - read GameSettings, camera shake integration
- `scripts/main.gd` - new menu buttons
- `scenes/main.tscn` - Options button, route to char select
- `scenes/game.tscn` - add Camera2D
- `scenes/stage.tscn` - dynamic background loading
- `scripts/combat/hitbox.gd` - trigger VFX on hit
- `scripts/states/attack_state.gd` - hitlag on heavy attacks
- `scripts/states/ko_state.gd` - KO effects
- `scripts/audio_manager.gd` - new sounds, volume control
- `project.godot` - new autoloads
