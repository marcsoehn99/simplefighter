extends Resource
class_name AttackData

@export var attack_name: String = ""
@export var damage: int = 5
@export var chip_damage: int = 1
@export var knockback: Vector2 = Vector2(200, 0)
@export var stun_frames: int = 12
@export var startup_frames: int = 3
@export var active_frames: int = 3
@export var recovery_frames: int = 8
@export var hitbox_offset: Vector2 = Vector2(50, -50)
@export var hitbox_size: Vector2 = Vector2(40, 30)
@export var is_special: bool = false
@export var is_projectile: bool = false
@export var projectile_speed: float = 400.0

var active_start: int:
	get: return startup_frames

var active_end: int:
	get: return startup_frames + active_frames

var total_frames: int:
	get: return startup_frames + active_frames + recovery_frames
