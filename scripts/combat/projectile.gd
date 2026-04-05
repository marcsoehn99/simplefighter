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
	var shape = CircleShape2D.new()
	shape.radius = 16.0
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)

	# Hadoken energy ball visual (drawn via _draw)
	add_child(_create_hadoken_visual())

	# Core glow particles
	var core = GPUParticles2D.new()
	var core_mat = ParticleProcessMaterial.new()
	core_mat.direction = Vector3(0, 0, 0)
	core_mat.spread = 180.0
	core_mat.initial_velocity_min = 10.0
	core_mat.initial_velocity_max = 30.0
	core_mat.gravity = Vector3.ZERO
	core_mat.scale_min = 2.0
	core_mat.scale_max = 5.0
	core_mat.color = Color(0.6, 0.85, 1.0, 0.8)
	core.process_material = core_mat
	core.amount = 12
	core.lifetime = 0.15
	core.emitting = true
	core.explosiveness = 0.3
	add_child(core)

	# Trailing particles
	var trail = GPUParticles2D.new()
	var trail_mat = ParticleProcessMaterial.new()
	trail_mat.direction = Vector3(-direction, 0, 0)
	trail_mat.spread = 20.0
	trail_mat.initial_velocity_min = 30.0
	trail_mat.initial_velocity_max = 80.0
	trail_mat.gravity = Vector3.ZERO
	trail_mat.scale_min = 2.0
	trail_mat.scale_max = 4.0
	trail_mat.color = Color(0.3, 0.5, 1.0, 0.6)
	trail.process_material = trail_mat
	trail.amount = 16
	trail.lifetime = 0.4
	trail.emitting = true
	add_child(trail)

	area_entered.connect(_on_area_entered)

func _create_hadoken_visual() -> Node2D:
	var visual = Node2D.new()
	visual.set_script(_hadoken_draw_script())
	return visual

func _hadoken_draw_script() -> GDScript:
	var script = GDScript.new()
	script.source_code = """extends Node2D

var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	# Outer glow
	draw_circle(Vector2.ZERO, 22.0 + sin(time * 12.0) * 3.0, Color(0.1, 0.3, 0.8, 0.3))
	# Mid ring
	draw_circle(Vector2.ZERO, 16.0 + sin(time * 15.0) * 2.0, Color(0.2, 0.5, 1.0, 0.5))
	# Inner core
	draw_circle(Vector2.ZERO, 10.0 + sin(time * 20.0) * 1.5, Color(0.5, 0.8, 1.0, 0.8))
	# Bright center
	draw_circle(Vector2.ZERO, 5.0, Color(0.9, 0.95, 1.0, 0.95))
"""
	script.reload()
	return script

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
			VFXManager.spawn_hit_spark(global_position, "heavy")
			queue_free()
