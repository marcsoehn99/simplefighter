extends Area2D

var speed: float = 400.0
var damage: int = 10
var chip_damage: int = 3
var knockback: Vector2 = Vector2(300, -100)
var stun_frames: int = 18
var direction: float = 1.0
var owner_fighter: CharacterBody2D
var owner_player_id: int = 1

func _ready() -> void:
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 16)
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)

	var visual = ColorRect.new()
	visual.size = Vector2(24, 16)
	visual.position = Vector2(-12, -8)
	visual.color = Color(0.2, 0.6, 1.0, 0.9)
	add_child(visual)

	area_entered.connect(_on_area_entered)

func setup(fighter: CharacterBody2D, dir: float, spd: float, player_id: int) -> void:
	owner_fighter = fighter
	direction = dir
	speed = spd
	owner_player_id = player_id

	if player_id == 1:
		collision_layer = 1 << 3
		collision_mask = 1 << 2
	else:
		collision_layer = 1 << 4
		collision_mask = 1 << 1

func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta
	if position.x < -100 or position.x > 1400:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		var target = area.owner_fighter
		if target != owner_fighter:
			var kb = knockback
			if direction < 0:
				kb.x = -kb.x
			target.take_damage(damage, kb, stun_frames, chip_damage)
			AudioManager.play("projectile_hit")
			queue_free()
