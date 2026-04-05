extends CharacterBody2D

signal health_changed(new_health: int)
signal fighter_ko(fighter: CharacterBody2D)
signal meter_changed(new_meter: int)

const GRAVITY: float = 1800.0
const MOVE_SPEED: float = 300.0
const JUMP_VELOCITY: float = -700.0
const MAX_HEALTH: int = 100
const MAX_SUPER: int = 100

@export var player_id: int = 1
@export var is_ai: bool = false
@export var fighter_id: String = "fighter_01"

var health: int = MAX_HEALTH
var super_meter: int = 0
var facing_right: bool = true
var opponent: CharacterBody2D
var can_act: bool = true
var hits_landed_this_attack: Array = []
var is_knocked_out: bool = false
var input_prefix: String = "p1_"
var visual_color: Color = Color.CORNFLOWER_BLUE
var _default_sprite_pos: Vector2

# Per-fighter special move definitions: motion + buttons → attack name
const FIGHTER_SPECIALS := {
	"fighter_01": [
		{"motion": "dp", "buttons": ["lp", "hp"], "attack": "dragon_punch"},
		{"motion": "qcf", "buttons": ["lp", "hp"], "attack": "fireball"},
		{"motion": "qcf", "buttons": ["lk", "hk"], "attack": "tornado_kick"},
	],
	"fighter_02": [
		{"motion": "dp", "buttons": ["lp", "hp"], "attack": "dragon_punch"},
		{"motion": "qcf", "buttons": ["lp", "hp"], "attack": "fireball"},
		{"motion": "qcf", "buttons": ["lk", "hk"], "attack": "tornado_kick"},
	],
	"fighter_03": [
		{"motion": "dp", "buttons": ["lp", "hp"], "attack": "dragon_punch"},
		{"motion": "qcf", "buttons": ["lp", "hp"], "attack": "fireball"},
		{"motion": "qcf", "buttons": ["lk", "hk"], "attack": "tornado_kick"},
	],
	"fighter_04": [  # TETSUO (Sumo)
		{"motion": "qcf", "buttons": ["lp", "hp"], "attack": "sumo_charge"},
		{"motion": "dp", "buttons": ["lp", "hp"], "attack": "palm_strike"},
		{"motion": "qcf", "buttons": ["lk", "hk"], "attack": "ground_stomp"},
	],
	"fighter_05": [  # TITAN (Wrestler)
		{"motion": "qcf", "buttons": ["lp", "hp"], "attack": "clothesline"},
		{"motion": "qcf", "buttons": ["lk", "hk"], "attack": "body_splash"},
		{"motion": "dp", "buttons": ["lp", "hp"], "attack": "gorilla_press"},
	],
	"fighter_06": [  # KENSHI (Samurai)
		{"motion": "qcf", "buttons": ["lp", "hp"], "attack": "sword_wave"},
		{"motion": "dp", "buttons": ["lp", "hp"], "attack": "rising_slash"},
		{"motion": "qcf", "buttons": ["lk", "hk"], "attack": "whirlwind_slash"},
	],
	"fighter_07": [  # NARUTO
		{"motion": "qcf", "buttons": ["lp", "hp"], "attack": "rasengan"},
		{"motion": "qcf", "buttons": ["lk", "hk"], "attack": "shadow_clone"},
		{"motion": "dp", "buttons": ["lp", "hp"], "attack": "rasenshuriken"},
	],
}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var state_machine: StateMachine = $StateMachine
@onready var input_buffer: InputBuffer = $InputBuffer
var ai_controller = null

func _ready() -> void:
	input_prefix = "p1_" if player_id == 1 else "p2_"

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

	# Normalize sprite scale so all fighters appear the same size
	var frame_h = SpriteLoader.get_frame_height(fighter_id)
	var target_scale = 3.0 * (92.0 / frame_h)
	sprite.scale = Vector2(target_scale, target_scale)
	# Position sprite so bottom edge aligns with fighter origin (feet on floor)
	var visual_height = frame_h * target_scale
	sprite.position = Vector2(0, -(visual_height / 2.0))
	_default_sprite_pos = sprite.position

	# Initialize state machine now that sprite is ready
	state_machine.initialize(self)

	# Auto-detect controller: if P2 and a gamepad is connected, disable AI
	if player_id == 2 and is_ai and Input.get_connected_joypads().size() > 0:
		is_ai = false

	if is_ai:
		var AIC = load("res://scripts/ai/ai_controller.gd")
		ai_controller = AIC.new()
		ai_controller.fighter = self
		add_child(ai_controller)

func _physics_process(_delta: float) -> void:
	if opponent and not is_knocked_out:
		var was_facing_right = facing_right
		facing_right = global_position.x < opponent.global_position.x
		if was_facing_right != facing_right:
			_update_facing()

	input_buffer.update()

func _update_facing() -> void:
	sprite.flip_h = not facing_right

func play_anim(anim_name: String) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		# Fallback: try idle
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")

func is_input_pressed(action: String) -> bool:
	if is_ai and ai_controller:
		return ai_controller.is_action_pressed(action)
	return Input.is_action_pressed(input_prefix + action)

func is_input_just_pressed(action: String) -> bool:
	if is_ai and ai_controller:
		return ai_controller.is_action_just_pressed(action)
	return Input.is_action_just_pressed(input_prefix + action)

func is_blocking() -> bool:
	if not is_on_floor():
		return false
	if is_ai and ai_controller:
		return ai_controller.is_action_pressed("block")
	var holding_back = false
	if facing_right:
		holding_back = is_input_pressed("left")
	else:
		holding_back = is_input_pressed("right")
	return holding_back

func take_damage(amount: int, knockback: Vector2, stun: int, chip: int = 0) -> void:
	if is_knocked_out:
		return

	if is_blocking():
		health -= chip
		add_meter(chip * 2)  # Defender gains meter on block
		if health <= 0:
			health = 0
			health_changed.emit(health)
			_do_ko()
			return
		health_changed.emit(health)
		state_machine.transition_to("blockstun", {"stun_frames": maxi(stun / 2, 6), "knockback": knockback * 0.3})
	else:
		health -= amount
		add_meter(int(amount * 1.5))  # Defender gains more meter on hit
		if health <= 0:
			health = 0
			health_changed.emit(health)
			_do_ko()
			return
		health_changed.emit(health)
		state_machine.transition_to("hitstun", {"stun_frames": stun, "knockback": knockback})

func _do_ko() -> void:
	is_knocked_out = true
	can_act = false
	state_machine.transition_to("ko", {})
	fighter_ko.emit(self)

func reset_fighter(pos: Vector2) -> void:
	global_position = pos
	health = MAX_HEALTH
	super_meter = 0
	is_knocked_out = false
	can_act = true
	velocity = Vector2.ZERO
	hits_landed_this_attack.clear()
	# Reset sprite visuals from KO/stun states
	sprite.rotation_degrees = 0
	sprite.position = _default_sprite_pos
	sprite.modulate = Color.WHITE
	health_changed.emit(health)
	meter_changed.emit(super_meter)
	state_machine.transition_to("idle", {})

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func get_attack_data(attack_name: String) -> AttackData:
	# Check fighter-specific override first
	var fighter_path = "res://resources/attacks/" + fighter_id + "/" + attack_name + ".tres"
	if ResourceLoader.exists(fighter_path):
		return load(fighter_path) as AttackData
	var path = "res://resources/attacks/" + attack_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path) as AttackData
	return null

func check_special_input() -> String:
	var specials = FIGHTER_SPECIALS.get(fighter_id, [])
	for spec in specials:
		var button_pressed = false
		for btn in spec["buttons"]:
			if is_input_just_pressed(btn):
				button_pressed = true
				break
		if not button_pressed:
			continue
		var motion_ok = false
		match spec["motion"]:
			"qcf":
				motion_ok = input_buffer.check_qcf()
			"dp":
				motion_ok = input_buffer.check_dp()
		if motion_ok:
			return spec["attack"]
	return ""

func check_super_input() -> bool:
	return super_meter >= MAX_SUPER and is_input_just_pressed("super")

func use_super() -> void:
	super_meter = 0
	meter_changed.emit(super_meter)
	AudioManager.play("energy_charge")
	VFXManager.screen_flash(Color(1, 1, 0.5, 0.6), 0.15)
	state_machine.transition_to("attack", {"attack_name": "super_attack"})

func add_meter(amount: int) -> void:
	if is_knocked_out:
		return
	super_meter = mini(super_meter + amount, MAX_SUPER)
	meter_changed.emit(super_meter)

func spawn_projectile(spd: float) -> void:
	var proj_scene = load("res://scenes/projectile.tscn")
	var proj = proj_scene.instantiate()
	var dir = 1.0 if facing_right else -1.0
	proj.global_position = global_position + Vector2(80 * dir, -80)
	proj.setup(self, dir, spd, player_id)
	get_parent().add_child(proj)
