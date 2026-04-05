# UI, Visual Polish & Stages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add character select, stage select, options menus, VFX (screen shake, hit particles, KO flash/slowmo), dynamic stage backgrounds, and announcer voice lines to a Godot 4.6.1 fighting game.

**Architecture:** New `GameSettings` autoload carries all menu selections (fighter IDs, stage, rounds, timer) between scenes. `VFXManager` autoload handles screen shake, particles, and slowmo globally. Menu screens chain: Main → Character Select → Stage Select → Game. SpriteLoader refactored from hardcoded p1/p2 to dynamic loading by fighter ID.

**Tech Stack:** Godot 4.6.1, GDScript, GPUParticles2D, Camera2D, gopeak MCP for scene operations.

---

## File Structure

### New Files
| File | Responsibility |
|------|---------------|
| `scripts/game_settings.gd` | Autoload: stores menu selections (fighters, stage, rounds, timer, volume) |
| `scripts/vfx_manager.gd` | Autoload: screen shake, hit sparks, screen flash, slowmo, hitlag |
| `scripts/ui/character_select.gd` | Character selection logic for both players |
| `scripts/ui/stage_select.gd` | Stage selection logic |
| `scripts/ui/options.gd` | Options menu logic (volume, rounds, timer) |
| `scenes/ui/character_select.tscn` | Character select scene (built via gopeak) |
| `scenes/ui/stage_select.tscn` | Stage select scene (built via gopeak) |
| `scenes/ui/options.tscn` | Options scene (built via gopeak) |

### Modified Files
| File | Changes |
|------|---------|
| `project.godot` | Add GameSettings + VFXManager autoloads |
| `scripts/sprite_loader.gd` | Refactor to `load_fighter_frames(fighter_id)`, remove hardcoded p1/p2 |
| `scripts/fighter.gd` | Add `fighter_id` export, load sprites by ID from GameSettings |
| `scripts/game_manager.gd` | Read GameSettings for rounds/timer, integrate camera shake |
| `scripts/main.gd` | Route FIGHT to character select, add OPTIONS button handler |
| `scenes/main.tscn` | Add OPTIONS button between FIGHT and QUIT |
| `scenes/game.tscn` | Add Camera2D node |
| `scenes/stage.tscn` | Remove hardcoded background texture (loaded dynamically) |
| `scripts/combat/hitbox.gd` | Call VFXManager on hit for sparks |
| `scripts/states/attack_state.gd` | Add hitlag on heavy attacks |
| `scripts/states/ko_state.gd` | Add KO flash + slowmo via VFXManager |
| `scripts/audio_manager.gd` | Add announcer sounds, rename files, volume control |
| `scripts/combat/projectile.gd` | Add particle trail to fireballs |

### Asset Reorganization
```
assets/fighters/fighter_01/sheets/  (move from assets/p1/sheets/)
assets/fighters/fighter_02/sheets/  (new - PixelLab Ryu-type)
assets/fighters/fighter_03/sheets/  (new - PixelLab Villain)
assets/stages/dojo/background.png   (current background)
assets/stages/rooftop/background.png (new - PixelLab)
assets/stages/temple/background.png  (new - PixelLab)
assets/sounds/announcer/             (rename TTS files to clean names)
```

---

### Task 1: Rename & Reorganize Audio Assets

**Files:**
- Rename: `assets/sounds/announcer/tts_*` → clean names
- Rename: `assets/sounds/sfx_*` → clean names

- [ ] **Step 1: Rename announcer files to clean names**

```bash
cd /Users/marcsoehn/simplefighter/assets/sounds/announcer
mv "tts_ROUND_20260405_125218.mp3" "round_1.mp3"
mv "tts_ROUND_20260405_125220.mp3" "round_2.mp3"
mv "tts_ROUND_20260405_125221.mp3" "round_3.mp3"
mv "tts_FIGHT_20260405_125222.mp3" "fight.mp3"
mv "tts_K!_O!_20260405_125223.mp3" "ko.mp3"
mv "tts_PLAYE_20260405_125225.mp3" "p1_wins.mp3"
mv "tts_PLAYE_20260405_125226.mp3" "p2_wins.mp3"
mv "tts_PERFE_20260405_125228.mp3" "perfect.mp3"
mv "tts_SELEC_20260405_125229.mp3" "select_fighter.mp3"
mv "tts_CHOOS_20260405_125231.mp3" "choose_stage.mp3"
mv "tts_TIME__20260405_125232.mp3" "time_over.mp3"
```

- [ ] **Step 2: Rename SFX files**

```bash
cd /Users/marcsoehn/simplefighter/assets/sounds
mv "sfx_Heavy_20260405_125129.mp3" "heavy_impact.mp3"
mv "sfx_Energ_20260405_125131.mp3" "energy_charge.mp3"
mv "sfx_Risin_20260405_125133.mp3" "dp_whoosh.mp3"
```

- [ ] **Step 3: Reorganize fighter sprites to new folder structure**

```bash
cd /Users/marcsoehn/simplefighter/assets
mkdir -p fighters/fighter_01/sheets
cp p1/sheets/*.png fighters/fighter_01/sheets/
mkdir -p fighters/fighter_02/sheets
mkdir -p fighters/fighter_03/sheets
mkdir -p stages/dojo
cp stage/background_scaled.png stages/dojo/background.png
mkdir -p stages/rooftop
mkdir -p stages/temple
```

Note: fighter_02 and fighter_03 sprites will be added later from PixelLab downloads. Stage backgrounds for rooftop/temple will also be added from PixelLab.

- [ ] **Step 4: Commit**

```bash
git add assets/
git commit -m "chore: reorganize assets into fighters/ and stages/ structure, rename audio files"
```

---

### Task 2: GameSettings Autoload

**Files:**
- Create: `scripts/game_settings.gd`
- Modify: `project.godot`

- [ ] **Step 1: Create GameSettings script**

```gdscript
# scripts/game_settings.gd
extends Node

var p1_fighter: String = "fighter_01"
var p2_fighter: String = "fighter_01"
var stage_id: String = "dojo"
var p2_is_ai: bool = true
var rounds_to_win: int = 2
var round_timer: int = 99
var sfx_volume: float = 1.0
var music_volume: float = 1.0

func apply_audio_settings() -> void:
	var sfx_db = linear_to_db(sfx_volume) if sfx_volume > 0 else -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), sfx_db)
```

- [ ] **Step 2: Add autoload to project.godot**

In `project.godot`, add `GameSettings` to the `[autoload]` section, before SpriteLoader:

```
GameSettings="*res://scripts/game_settings.gd"
```

- [ ] **Step 3: Verify in Godot via gopeak**

Use gopeak `run-project` to confirm the game still launches without errors.

- [ ] **Step 4: Commit**

```bash
git add scripts/game_settings.gd project.godot
git commit -m "feat: add GameSettings autoload for menu selections"
```

---

### Task 3: VFX Manager Autoload

**Files:**
- Create: `scripts/vfx_manager.gd`
- Modify: `project.godot`

- [ ] **Step 1: Create VFXManager script**

```gdscript
# scripts/vfx_manager.gd
extends Node

var camera: Camera2D
var shake_intensity: float = 0.0
var shake_duration: float = 0.0

func _process(delta: float) -> void:
	if shake_duration > 0 and camera:
		shake_duration -= delta
		camera.offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		if shake_duration <= 0:
			camera.offset = Vector2.ZERO

func register_camera(cam: Camera2D) -> void:
	camera = cam

func screen_shake(intensity: float, duration: float = 0.3) -> void:
	shake_intensity = intensity
	shake_duration = duration

func spawn_hit_spark(pos: Vector2, type: String = "light") -> void:
	var particles = GPUParticles2D.new()
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 45.0
	mat.initial_velocity_min = 100.0
	mat.initial_velocity_max = 200.0
	mat.gravity = Vector3(0, 300, 0)
	mat.scale_min = 2.0
	mat.scale_max = 4.0

	match type:
		"light":
			particles.amount = 12
			particles.lifetime = 0.2
			mat.color = Color(1.0, 1.0, 0.8)
		"heavy":
			particles.amount = 20
			particles.lifetime = 0.3
			mat.spread = 60.0
			mat.initial_velocity_max = 300.0
			mat.color = Color(1.0, 0.6, 0.2)
			screen_shake(6.0, 0.2)
		"block":
			particles.amount = 8
			particles.lifetime = 0.15
			mat.color = Color(0.4, 0.7, 1.0)

	particles.process_material = mat
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.global_position = pos

	var game_root = get_tree().current_scene
	if game_root:
		game_root.add_child(particles)
		get_tree().create_timer(1.0).timeout.connect(particles.queue_free)

func screen_flash(color: Color = Color.WHITE, duration: float = 0.1) -> void:
	var flash = ColorRect.new()
	flash.color = color
	flash.anchors_preset = Control.PRESET_FULL_RECT
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var canvas = CanvasLayer.new()
	canvas.layer = 100
	canvas.add_child(flash)

	var game_root = get_tree().current_scene
	if game_root:
		game_root.add_child(canvas)
		get_tree().create_timer(duration).timeout.connect(canvas.queue_free)

func slowmo(time_scale: float = 0.3, duration: float = 0.5) -> void:
	Engine.time_scale = time_scale
	get_tree().create_timer(duration * time_scale).timeout.connect(_restore_time_scale)

func _restore_time_scale() -> void:
	Engine.time_scale = 1.0

func hitlag(frames: int = 3) -> void:
	Engine.time_scale = 0.0
	get_tree().create_timer(frames / 60.0).timeout.connect(_restore_time_scale)
```

- [ ] **Step 2: Add autoload to project.godot**

In `project.godot`, add to `[autoload]` section:

```
VFXManager="*res://scripts/vfx_manager.gd"
```

- [ ] **Step 3: Verify in Godot via gopeak**

Use gopeak `run-project` to confirm game still launches.

- [ ] **Step 4: Commit**

```bash
git add scripts/vfx_manager.gd project.godot
git commit -m "feat: add VFXManager autoload for screen shake, particles, flash, slowmo"
```

---

### Task 4: Refactor SpriteLoader for Dynamic Fighter Loading

**Files:**
- Modify: `scripts/sprite_loader.gd`

- [ ] **Step 1: Refactor SpriteLoader to load by fighter ID**

Replace the entire content of `scripts/sprite_loader.gd`:

```gdscript
extends Node

const FRAME_HEIGHT := 92

const ANIMS := {
	"idle":         {"file": "idle.png",         "fps": 8.0,  "loop": true},
	"walk":         {"file": "walk.png",         "fps": 10.0, "loop": true},
	"jump":         {"file": "jump.png",         "fps": 12.0, "loop": false},
	"crouch":       {"file": "crouch.png",       "fps": 10.0, "loop": false},
	"stand_lp":     {"file": "stand_lp.png",     "fps": 15.0, "loop": false},
	"stand_hp":     {"file": "stand_hp.png",     "fps": 12.0, "loop": false},
	"stand_lk":     {"file": "stand_lk.png",     "fps": 15.0, "loop": false},
	"stand_hk":     {"file": "stand_hk.png",     "fps": 12.0, "loop": false},
	"fireball":     {"file": "fireball.png",     "fps": 12.0, "loop": false},
	"dragon_punch": {"file": "dragon_punch.png", "fps": 15.0, "loop": false},
	"crouch_hk":    {"file": "crouch_hk.png",    "fps": 12.0, "loop": false},
	"hit_stun":     {"file": "hit_stun.png",     "fps": 10.0, "loop": false},
	"ko":           {"file": "ko.png",           "fps": 8.0,  "loop": false},
}

var _cache: Dictionary = {}

func load_fighter_frames(fighter_id: String) -> SpriteFrames:
	if fighter_id in _cache:
		return _cache[fighter_id]

	var base_path = "res://assets/fighters/" + fighter_id + "/sheets/"
	var sf = _build_sprite_frames(base_path)
	_cache[fighter_id] = sf
	return sf

func _build_sprite_frames(base_path: String) -> SpriteFrames:
	var sf = SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")

	for anim_name in ANIMS:
		var info: Dictionary = ANIMS[anim_name]
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, info["fps"])
		sf.set_animation_loop(anim_name, info["loop"])

		var full_path = base_path + info["file"]
		if not ResourceLoader.exists(full_path):
			push_warning("Could not load: " + full_path)
			continue

		var texture: Texture2D = load(full_path)
		if texture == null:
			continue

		var frame_w: int = FRAME_HEIGHT
		var frame_h: int = texture.get_height()
		var frame_count: int = maxi(1, texture.get_width() / frame_w)

		for i in frame_count:
			var atlas = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * frame_w, 0, frame_w, frame_h)
			sf.add_frame(anim_name, atlas)

	return sf
```

- [ ] **Step 2: Verify in Godot**

Use gopeak to run and confirm no errors (fighters won't load yet until fighter.gd is updated).

- [ ] **Step 3: Commit**

```bash
git add scripts/sprite_loader.gd
git commit -m "refactor: SpriteLoader to dynamic fighter loading by ID with caching"
```

---

### Task 5: Update Fighter for Dynamic Character Selection

**Files:**
- Modify: `scripts/fighter.gd`

- [ ] **Step 1: Add fighter_id and load sprites dynamically**

In `scripts/fighter.gd`, add an export var after the existing exports:

```gdscript
@export var fighter_id: String = "fighter_01"
```

Replace the sprite loading section in `_ready()` (lines 33-43) with:

```gdscript
	# Load fighter sprites from GameSettings
	if player_id == 1:
		fighter_id = GameSettings.p1_fighter
		hurtbox.collision_layer = 1 << 1
		hitbox.collision_layer = 1 << 3
		hitbox.collision_mask = 1 << 2
	else:
		fighter_id = GameSettings.p2_fighter
		is_ai = GameSettings.p2_is_ai
		hurtbox.collision_layer = 1 << 2
		hitbox.collision_layer = 1 << 4
		hitbox.collision_mask = 1 << 1

	sprite.sprite_frames = SpriteLoader.load_fighter_frames(fighter_id)
```

- [ ] **Step 2: Verify in Godot via gopeak**

Run the project — it should load fighter_01 sprites from the new `assets/fighters/fighter_01/sheets/` path.

- [ ] **Step 3: Commit**

```bash
git add scripts/fighter.gd
git commit -m "feat: fighter loads sprites dynamically from GameSettings fighter selection"
```

---

### Task 6: Update Game Manager to Read GameSettings

**Files:**
- Modify: `scripts/game_manager.gd`

- [ ] **Step 1: Replace constants with GameSettings values**

In `scripts/game_manager.gd`, remove the `ROUNDS_TO_WIN` constant (line 14) and change `round_timer` init (line 9) and `_start_round()`:

Replace lines 9 and 14:
```gdscript
var round_timer: float = 99.0
```
to:
```gdscript
var round_timer: float = 99.0
```

Remove `const ROUNDS_TO_WIN := 2` entirely.

In `_ready()`, add at the top before the existing code:

```gdscript
	# Apply settings from menu
	fighter2.is_ai = GameSettings.p2_is_ai
```

In `_start_round()`, replace `round_timer = 99.0` with:
```gdscript
	round_timer = float(GameSettings.round_timer)
```

And replace `hud.update_timer(99)` with:
```gdscript
	hud.update_timer(GameSettings.round_timer)
```

In `_physics_process`, in the `Phase.ROUND_END` block, replace both occurrences of `ROUNDS_TO_WIN` with `GameSettings.rounds_to_win`.

- [ ] **Step 2: Commit**

```bash
git add scripts/game_manager.gd
git commit -m "feat: game_manager reads rounds/timer from GameSettings"
```

---

### Task 7: Add Camera2D for Screen Shake

**Files:**
- Modify: `scenes/game.tscn` (via gopeak)
- Modify: `scripts/game_manager.gd`

- [ ] **Step 1: Add Camera2D to game scene via gopeak**

Use gopeak `add-node` to add a Camera2D node to the Game scene:
- Parent: Game (root)
- Type: Camera2D
- Name: Camera2D
- Properties: `position = Vector2(640, 360)`, `enabled = true`

- [ ] **Step 2: Register camera with VFXManager in game_manager.gd**

In `scripts/game_manager.gd`, add `@onready var camera: Camera2D = $Camera2D` with the other @onready vars.

At the top of `_ready()`, add:
```gdscript
	VFXManager.register_camera(camera)
```

- [ ] **Step 3: Verify in Godot**

Run via gopeak — camera should center on the stage.

- [ ] **Step 4: Commit**

```bash
git add scenes/game.tscn scripts/game_manager.gd
git commit -m "feat: add Camera2D to game scene, register with VFXManager"
```

---

### Task 8: Add Hit VFX to Combat

**Files:**
- Modify: `scripts/combat/hitbox.gd`
- Modify: `scripts/states/attack_state.gd`
- Modify: `scripts/states/ko_state.gd`
- Modify: `scripts/combat/projectile.gd`

- [ ] **Step 1: Add hit sparks to hitbox.gd**

In `scripts/combat/hitbox.gd`, at the end of `_on_area_entered`, after `target.take_damage(...)`, add:

```gdscript
			# VFX
			var hit_pos = (owner_fighter.global_position + target.global_position) / 2.0
			hit_pos.y -= 60  # Offset to body center
			if target.is_blocking():
				VFXManager.spawn_hit_spark(hit_pos, "block")
			elif attack_data.damage >= 10:
				VFXManager.spawn_hit_spark(hit_pos, "heavy")
			else:
				VFXManager.spawn_hit_spark(hit_pos, "light")
```

- [ ] **Step 2: Add hitlag on heavy attacks in attack_state.gd**

In `scripts/states/attack_state.gd`, in the `state_physics_process` function, right after `fighter.hitbox.activate(attack_data)` (around frame_counter == active_start block), add after the activate call:

No change needed here — hitlag is triggered on contact. Instead, modify the hitbox `_on_area_entered` to add hitlag for heavy attacks.

Back in `scripts/combat/hitbox.gd`, after the VFX code just added, add:

```gdscript
			if attack_data.damage >= 10:
				VFXManager.hitlag(3)
```

- [ ] **Step 3: Add KO effects to ko_state.gd**

In `scripts/states/ko_state.gd`, in `enter()`, after `fighter.play_anim("ko")`, add:

```gdscript
	VFXManager.screen_flash(Color.WHITE, 0.1)
	VFXManager.screen_shake(10.0, 0.4)
	VFXManager.slowmo(0.3, 0.5)
```

- [ ] **Step 4: Add particle trail to projectile.gd**

In `scripts/combat/projectile.gd`, in `_ready()`, before `area_entered.connect(...)`, add:

```gdscript
	# Particle trail
	var trail = GPUParticles2D.new()
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(-direction, 0, 0)
	mat.spread = 15.0
	mat.initial_velocity_min = 20.0
	mat.initial_velocity_max = 40.0
	mat.gravity = Vector3.ZERO
	mat.scale_min = 1.5
	mat.scale_max = 3.0
	mat.color = Color(0.2, 0.6, 1.0, 0.7)
	trail.process_material = mat
	trail.amount = 8
	trail.lifetime = 0.3
	trail.emitting = true
	add_child(trail)
```

- [ ] **Step 5: Add hit spark to projectile hit**

In `scripts/combat/projectile.gd`, in `_on_area_entered`, before `queue_free()`, add:

```gdscript
			VFXManager.spawn_hit_spark(global_position, "heavy")
```

- [ ] **Step 6: Verify in Godot**

Run via gopeak, land some hits — should see sparks, screen shake on heavy attacks, and flash/slowmo on KO.

- [ ] **Step 7: Commit**

```bash
git add scripts/combat/hitbox.gd scripts/states/attack_state.gd scripts/states/ko_state.gd scripts/combat/projectile.gd
git commit -m "feat: add hit sparks, screen shake, hitlag, KO flash/slowmo, fireball trail"
```

---

### Task 9: Update Audio Manager with Announcer + Volume Control

**Files:**
- Modify: `scripts/audio_manager.gd`

- [ ] **Step 1: Add new sound entries and volume control**

In `scripts/audio_manager.gd`, add these entries to `SOUND_FILES`:

```gdscript
	"announce_round_1": "res://assets/sounds/announcer/round_1.mp3",
	"announce_round_2": "res://assets/sounds/announcer/round_2.mp3",
	"announce_round_3": "res://assets/sounds/announcer/round_3.mp3",
	"announce_fight": "res://assets/sounds/announcer/fight.mp3",
	"announce_ko": "res://assets/sounds/announcer/ko.mp3",
	"announce_p1_wins": "res://assets/sounds/announcer/p1_wins.mp3",
	"announce_p2_wins": "res://assets/sounds/announcer/p2_wins.mp3",
	"announce_perfect": "res://assets/sounds/announcer/perfect.mp3",
	"announce_select_fighter": "res://assets/sounds/announcer/select_fighter.mp3",
	"announce_choose_stage": "res://assets/sounds/announcer/choose_stage.mp3",
	"announce_time_over": "res://assets/sounds/announcer/time_over.mp3",
	"heavy_impact": "res://assets/sounds/heavy_impact.mp3",
	"energy_charge": "res://assets/sounds/energy_charge.mp3",
	"dp_whoosh": "res://assets/sounds/dp_whoosh.mp3",
```

- [ ] **Step 2: Update game_manager.gd to use announcer sounds**

In `scripts/game_manager.gd`:

In `_start_round()`, replace `AudioManager.play("round_start")` with:
```gdscript
	var round_sound = "announce_round_" + str(round_number)
	AudioManager.play(round_sound)
```

In `_physics_process` Phase.INTRO block, where "FIGHT!" splash is shown (around `phase_timer <= 0.5`), add after `hud.show_splash("FIGHT!")`:
```gdscript
					AudioManager.play("announce_fight")
```

In `_on_fighter_ko`, replace `AudioManager.play("ko_announce")` with:
```gdscript
	AudioManager.play("announce_ko")
```

In Phase.ROUND_END, where winner is announced, after `hud.show_splash(winner + " WINS!")`, replace `AudioManager.play("victory")` with:
```gdscript
						if p1_wins >= GameSettings.rounds_to_win:
							AudioManager.play("announce_p1_wins")
						else:
							AudioManager.play("announce_p2_wins")
						# Check for perfect
						var winner_fighter = fighter1 if p1_wins >= GameSettings.rounds_to_win else fighter2
						if winner_fighter.health >= 100:
							AudioManager.play("announce_perfect")
```

In `_time_over`, replace `AudioManager.play("time_over")` with:
```gdscript
	AudioManager.play("announce_time_over")
```

- [ ] **Step 3: Commit**

```bash
git add scripts/audio_manager.gd scripts/game_manager.gd
git commit -m "feat: add announcer voice lines and new SFX to audio manager"
```

---

### Task 10: Dynamic Stage Background Loading

**Files:**
- Modify: `scenes/stage.tscn` (add script)
- Create: stage loading logic in game_manager

- [ ] **Step 1: Add a script to the Stage scene for dynamic background**

Create a small script or handle it in game_manager. Simplest approach: game_manager loads the background texture after the scene is ready.

In `scripts/game_manager.gd`, in `_ready()`, after setting up opponents, add:

```gdscript
	# Load stage background
	var bg_path = "res://assets/stages/" + GameSettings.stage_id + "/background.png"
	if ResourceLoader.exists(bg_path):
		var bg_texture = load(bg_path)
		var bg_sprite = $Stage/Background
		if bg_sprite and bg_texture:
			bg_sprite.texture = bg_texture
```

- [ ] **Step 2: Verify in Godot**

Run via gopeak — should load the dojo background from the new path.

- [ ] **Step 3: Commit**

```bash
git add scripts/game_manager.gd
git commit -m "feat: dynamic stage background loading from GameSettings"
```

---

### Task 11: Options Screen

**Files:**
- Create: `scripts/ui/options.gd`
- Create: `scenes/ui/options.tscn` (via gopeak)

- [ ] **Step 1: Create options.gd script**

```gdscript
# scripts/ui/options.gd
extends Control

@onready var sfx_slider: HSlider = $VBoxContainer/SFXRow/SFXSlider
@onready var rounds_label: Label = $VBoxContainer/RoundsRow/RoundsValue
@onready var timer_label: Label = $VBoxContainer/TimerRow/TimerValue

var round_options := [1, 2, 3]
var timer_options := [60, 99, -1]  # -1 = infinite
var round_index: int = 1
var timer_index: int = 1

func _ready() -> void:
	sfx_slider.value = GameSettings.sfx_volume * 100.0
	round_index = round_options.find(GameSettings.rounds_to_win)
	if round_index == -1:
		round_index = 1
	timer_index = timer_options.find(GameSettings.round_timer)
	if timer_index == -1:
		timer_index = 1
	_update_labels()
	$VBoxContainer/SFXRow/SFXSlider.grab_focus()

func _update_labels() -> void:
	rounds_label.text = str(round_options[round_index])
	if timer_options[timer_index] == -1:
		timer_label.text = "INF"
	else:
		timer_label.text = str(timer_options[timer_index])

func _on_sfx_slider_value_changed(value: float) -> void:
	GameSettings.sfx_volume = value / 100.0
	GameSettings.apply_audio_settings()

func _on_rounds_left_pressed() -> void:
	round_index = (round_index - 1) % round_options.size()
	if round_index < 0:
		round_index = round_options.size() - 1
	GameSettings.rounds_to_win = round_options[round_index]
	_update_labels()

func _on_rounds_right_pressed() -> void:
	round_index = (round_index + 1) % round_options.size()
	GameSettings.rounds_to_win = round_options[round_index]
	_update_labels()

func _on_timer_left_pressed() -> void:
	timer_index = (timer_index - 1) % timer_options.size()
	if timer_index < 0:
		timer_index = timer_options.size() - 1
	GameSettings.round_timer = timer_options[timer_index]
	_update_labels()

func _on_timer_right_pressed() -> void:
	timer_index = (timer_index + 1) % timer_options.size()
	GameSettings.round_timer = timer_options[timer_index]
	_update_labels()

func _on_back_pressed() -> void:
	AudioManager.play("menu_select")
	get_tree().change_scene_to_file("res://scenes/main.tscn")
```

- [ ] **Step 2: Create options.tscn via gopeak**

Use gopeak `create-scene` to create `scenes/ui/options.tscn` with this structure:

```
Control (root, script: res://scripts/ui/options.gd)
  ColorRect "Background" (full rect, color: #1a1428)
  VBoxContainer (centered, 500x400)
    Label "Title" (text: "OPTIONS", center aligned)
    Control "Spacer" (min height 30)
    HBoxContainer "SFXRow"
      Label "SFXLabel" (text: "SFX VOLUME", min width 200)
      HSlider "SFXSlider" (min 0, max 100, value 100, min width 250)
    Control "Spacer2" (min height 15)
    HBoxContainer "RoundsRow"
      Label "RoundsLabel" (text: "ROUNDS TO WIN", min width 200)
      Button "RoundsLeft" (text: "<", min width 40)
      Label "RoundsValue" (text: "2", min width 60, center aligned)
      Button "RoundsRight" (text: ">", min width 40)
    Control "Spacer3" (min height 15)
    HBoxContainer "TimerRow"
      Label "TimerLabel" (text: "ROUND TIMER", min width 200)
      Button "TimerLeft" (text: "<", min width 40)
      Label "TimerValue" (text: "99", min width 60, center aligned)
      Button "TimerRight" (text: ">", min width 40)
    Control "Spacer4" (min height 40)
    Button "BackButton" (text: "BACK")
```

Connect signals:
- SFXSlider.value_changed → `_on_sfx_slider_value_changed`
- RoundsLeft.pressed → `_on_rounds_left_pressed`
- RoundsRight.pressed → `_on_rounds_right_pressed`
- TimerLeft.pressed → `_on_timer_left_pressed`
- TimerRight.pressed → `_on_timer_right_pressed`
- BackButton.pressed → `_on_back_pressed`

- [ ] **Step 3: Verify in Godot**

Test the scene directly via gopeak or by navigating to it.

- [ ] **Step 4: Commit**

```bash
git add scripts/ui/options.gd scenes/ui/options.tscn
git commit -m "feat: add Options screen with SFX volume, rounds, and timer settings"
```

---

### Task 12: Character Select Screen

**Files:**
- Create: `scripts/ui/character_select.gd`
- Create: `scenes/ui/character_select.tscn` (via gopeak)

- [ ] **Step 1: Create character_select.gd**

```gdscript
# scripts/ui/character_select.gd
extends Control

const FIGHTERS := ["fighter_01", "fighter_02", "fighter_03"]
const FIGHTER_NAMES := {"fighter_01": "BLITZ", "fighter_02": "RYUKEN", "fighter_03": "VENOM"}

var p1_index: int = 0
var p2_index: int = 0
var p1_ready: bool = false
var p2_ready: bool = false

@onready var p1_name_label: Label = $HBoxContainer/P1Panel/P1Name
@onready var p2_name_label: Label = $HBoxContainer/P2Panel/P2Name
@onready var p1_sprite: AnimatedSprite2D = $HBoxContainer/P1Panel/P1Preview
@onready var p2_sprite: AnimatedSprite2D = $HBoxContainer/P2Panel/P2Preview
@onready var p1_ready_label: Label = $HBoxContainer/P1Panel/P1Ready
@onready var p2_ready_label: Label = $HBoxContainer/P2Panel/P2Ready
@onready var ai_toggle: CheckButton = $HBoxContainer/P2Panel/AIToggle

func _ready() -> void:
	AudioManager.play("announce_select_fighter")
	ai_toggle.button_pressed = GameSettings.p2_is_ai
	_update_selection()

func _update_selection() -> void:
	p1_name_label.text = FIGHTER_NAMES[FIGHTERS[p1_index]]
	p2_name_label.text = FIGHTER_NAMES[FIGHTERS[p2_index]]

	# Load and preview idle animation
	p1_sprite.sprite_frames = SpriteLoader.load_fighter_frames(FIGHTERS[p1_index])
	p1_sprite.play("idle")
	p2_sprite.sprite_frames = SpriteLoader.load_fighter_frames(FIGHTERS[p2_index])
	p2_sprite.play("idle")
	p2_sprite.flip_h = true

	p1_ready_label.text = "READY!" if p1_ready else ""
	p2_ready_label.text = "READY!" if p2_ready else ""

func _input(event: InputEvent) -> void:
	# P1 controls (A/D to navigate, U to confirm)
	if not p1_ready:
		if event.is_action_pressed("p1_left"):
			p1_index = (p1_index - 1) % FIGHTERS.size()
			if p1_index < 0:
				p1_index = FIGHTERS.size() - 1
			AudioManager.play("menu_select")
			_update_selection()
		elif event.is_action_pressed("p1_right"):
			p1_index = (p1_index + 1) % FIGHTERS.size()
			AudioManager.play("menu_select")
			_update_selection()
		elif event.is_action_pressed("p1_lp"):
			p1_ready = true
			AudioManager.play("menu_select")
			_update_selection()
			_check_both_ready()

	# P2 controls (arrows/gamepad to navigate, confirm)
	if not p2_ready:
		if event.is_action_pressed("p2_left"):
			p2_index = (p2_index - 1) % FIGHTERS.size()
			if p2_index < 0:
				p2_index = FIGHTERS.size() - 1
			AudioManager.play("menu_select")
			_update_selection()
		elif event.is_action_pressed("p2_right"):
			p2_index = (p2_index + 1) % FIGHTERS.size()
			AudioManager.play("menu_select")
			_update_selection()
		elif event.is_action_pressed("p2_lp"):
			p2_ready = true
			AudioManager.play("menu_select")
			_update_selection()
			_check_both_ready()

func _check_both_ready() -> void:
	if p1_ready and p2_ready:
		GameSettings.p1_fighter = FIGHTERS[p1_index]
		GameSettings.p2_fighter = FIGHTERS[p2_index]
		GameSettings.p2_is_ai = ai_toggle.button_pressed
		get_tree().create_timer(0.5).timeout.connect(_go_to_stage_select)

func _go_to_stage_select() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/stage_select.tscn")
```

- [ ] **Step 2: Create character_select.tscn via gopeak**

Use gopeak `create-scene` to build `scenes/ui/character_select.tscn`:

```
Control (root, script: res://scripts/ui/character_select.gd, full rect)
  ColorRect "Background" (full rect, color: #1a1428)
  Label "Title" (text: "SELECT YOUR FIGHTER", top center, offset_top: 30)
  HBoxContainer (centered, 1100x500)
    VBoxContainer "P1Panel" (size_flags_horizontal: 3)
      Label "P1Label" (text: "PLAYER 1", center)
      AnimatedSprite2D "P1Preview" (scale: 3.0, position centered)
      Label "P1Name" (text: "BLITZ", center)
      Label "P1Ready" (text: "", center, color: green)
    Control "Spacer" (min width: 100)
    VBoxContainer "P2Panel" (size_flags_horizontal: 3)
      Label "P2Label" (text: "PLAYER 2", center)
      AnimatedSprite2D "P2Preview" (scale: 3.0, position centered)
      Label "P2Name" (text: "BLITZ", center)
      CheckButton "AIToggle" (text: "CPU", button_pressed: true)
      Label "P2Ready" (text: "", center, color: green)
  Label "Controls" (bottom center, text: "P1: A/D + U | P2: Arrows + Numpad4")
```

- [ ] **Step 3: Verify in Godot**

Test by changing main.gd to route to character select (done in Task 14).

- [ ] **Step 4: Commit**

```bash
git add scripts/ui/character_select.gd scenes/ui/character_select.tscn
git commit -m "feat: add Character Select screen with P1/P2 fighter selection"
```

---

### Task 13: Stage Select Screen

**Files:**
- Create: `scripts/ui/stage_select.gd`
- Create: `scenes/ui/stage_select.tscn` (via gopeak)

- [ ] **Step 1: Create stage_select.gd**

```gdscript
# scripts/ui/stage_select.gd
extends Control

const STAGES := ["dojo", "rooftop", "temple"]
const STAGE_NAMES := {"dojo": "DOJO", "rooftop": "ROOFTOP", "temple": "TEMPLE"}

var selected_index: int = 0

@onready var stage_name_label: Label = $VBoxContainer/StageName
@onready var preview: TextureRect = $VBoxContainer/Preview

func _ready() -> void:
	AudioManager.play("announce_choose_stage")
	_update_selection()

func _update_selection() -> void:
	var stage_id = STAGES[selected_index]
	stage_name_label.text = STAGE_NAMES[stage_id]

	var bg_path = "res://assets/stages/" + stage_id + "/background.png"
	if ResourceLoader.exists(bg_path):
		preview.texture = load(bg_path)
	else:
		preview.texture = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_left") or event.is_action_pressed("p2_left"):
		selected_index = (selected_index - 1) % STAGES.size()
		if selected_index < 0:
			selected_index = STAGES.size() - 1
		AudioManager.play("menu_select")
		_update_selection()
	elif event.is_action_pressed("p1_right") or event.is_action_pressed("p2_right"):
		selected_index = (selected_index + 1) % STAGES.size()
		AudioManager.play("menu_select")
		_update_selection()
	elif event.is_action_pressed("p1_lp") or event.is_action_pressed("p2_lp"):
		GameSettings.stage_id = STAGES[selected_index]
		AudioManager.play("menu_select")
		get_tree().change_scene_to_file("res://scenes/game.tscn")
```

- [ ] **Step 2: Create stage_select.tscn via gopeak**

Use gopeak `create-scene` to build `scenes/ui/stage_select.tscn`:

```
Control (root, script: res://scripts/ui/stage_select.gd, full rect)
  ColorRect "Background" (full rect, color: #1a1428)
  VBoxContainer (centered, 800x500)
    Label "Title" (text: "CHOOSE YOUR STAGE", center)
    Control "Spacer" (min height 20)
    TextureRect "Preview" (min size: 640x360, stretch_mode: keep_aspect_centered)
    Control "Spacer2" (min height 20)
    Label "StageName" (text: "DOJO", center, large font)
    Label "Controls" (text: "< A/D > to browse | U to select", center)
```

- [ ] **Step 3: Commit**

```bash
git add scripts/ui/stage_select.gd scenes/ui/stage_select.tscn
git commit -m "feat: add Stage Select screen with preview and navigation"
```

---

### Task 14: Update Main Menu Flow

**Files:**
- Modify: `scripts/main.gd`
- Modify: `scenes/main.tscn` (via gopeak)

- [ ] **Step 1: Add Options button to main.tscn via gopeak**

Use gopeak `add-node` to add a Button node to `VBoxContainer`, between StartButton and QuitButton:
- Name: "OptionsButton"
- Text: "OPTIONS"

Also add a spacer Control (min height 10) between OptionsButton and QuitButton.

Connect OptionsButton.pressed signal to `_on_options_button_pressed`.

- [ ] **Step 2: Update main.gd**

Replace `scripts/main.gd`:

```gdscript
extends Control

func _ready() -> void:
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed() -> void:
	AudioManager.play("menu_select")
	get_tree().change_scene_to_file("res://scenes/ui/character_select.tscn")

func _on_options_button_pressed() -> void:
	AudioManager.play("menu_select")
	get_tree().change_scene_to_file("res://scenes/ui/options.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
```

- [ ] **Step 3: Verify full flow in Godot**

Run via gopeak: Main → FIGHT → Character Select → Stage Select → Game. Also test Main → OPTIONS → Back.

- [ ] **Step 4: Commit**

```bash
git add scripts/main.gd scenes/main.tscn
git commit -m "feat: update main menu with options button and character select flow"
```

---

### Task 15: Download & Integrate PixelLab Character Assets

**Files:**
- Download: PixelLab character ZIPs
- Place: `assets/fighters/fighter_02/sheets/` and `assets/fighters/fighter_03/sheets/`

- [ ] **Step 1: Check PixelLab animation status**

Use `get_character` for both character IDs:
- fighter_02 (Ryu-type): `77cb9473-fbd9-45cd-ad4d-16ccc1f63899`
- fighter_03 (Villain): `cc880772-7054-4916-8c48-9dc8b47dfdb1`

Queue any remaining animations that failed due to slot limits.

- [ ] **Step 2: Download character ZIPs when ready**

```bash
curl --fail -o /tmp/fighter_02.zip "https://api.pixellab.ai/mcp/characters/77cb9473-fbd9-45cd-ad4d-16ccc1f63899/download"
curl --fail -o /tmp/fighter_03.zip "https://api.pixellab.ai/mcp/characters/cc880772-7054-4916-8c48-9dc8b47dfdb1/download"
```

- [ ] **Step 3: Extract and convert animations to sprite sheets**

PixelLab outputs individual frame PNGs per animation. Convert them to horizontal strip sprite sheets matching the expected format (92px frame height, horizontal strip).

For each animation, use ImageMagick to create the strip:
```bash
# Example for one animation:
cd /tmp/fighter_02/animations/idle/east
convert *.png +append /Users/marcsoehn/simplefighter/assets/fighters/fighter_02/sheets/idle.png
```

Repeat for all 13 animations per character. The frame height from PixelLab is 132px (canvas size), so the SpriteLoader FRAME_HEIGHT may need adjustment, OR resize frames to 92px height.

- [ ] **Step 4: Verify characters load in game**

Change GameSettings defaults temporarily to test fighter_02 and fighter_03.

- [ ] **Step 5: Commit**

```bash
git add assets/fighters/
git commit -m "feat: add fighter_02 (Ryuken) and fighter_03 (Venom) sprite sheets"
```

---

### Task 16: Regenerate & Integrate Stage Backgrounds

**Files:**
- Generate: 3 stage backgrounds via PixelLab `create_map_object`
- Place: `assets/stages/{dojo,rooftop,temple}/background.png`

- [ ] **Step 1: Generate stage backgrounds via PixelLab**

Use `create_map_object` for each stage:
- Dojo: "Side-view pixel art Japanese dojo interior, wooden floor, paper walls, lanterns, warm lighting, 1280x720"
- Rooftop: "Side-view pixel art cyberpunk rooftop at night, neon skyline, rain, 1280x720"
- Temple: "Side-view pixel art ancient stone temple, clouds, mystical energy, pillars, 1280x720"

- [ ] **Step 2: Download and place backgrounds**

Save each to `assets/stages/{id}/background.png`.

- [ ] **Step 3: Verify stages in game**

Test stage select → each stage should show the correct background.

- [ ] **Step 4: Commit**

```bash
git add assets/stages/
git commit -m "feat: add dojo, rooftop, and temple stage backgrounds"
```

---

### Task 17: Final Integration Test in Godot

- [ ] **Step 1: Run full game flow via gopeak**

Test the complete flow:
1. Main Menu → FIGHT → Character Select
2. P1 selects fighter_02, P2 selects fighter_03
3. Stage Select → choose rooftop
4. Fight: verify sprites load, attacks work, VFX (sparks, shake, particles)
5. KO: verify flash, slowmo, announcer
6. Match end → back to main menu
7. Main Menu → OPTIONS → adjust settings → BACK
8. FIGHT again → verify settings persist

- [ ] **Step 2: Fix any issues found**

- [ ] **Step 3: Final commit**

```bash
git add -A
git commit -m "feat: complete UI polish, VFX, stages, and character selection system"
```
