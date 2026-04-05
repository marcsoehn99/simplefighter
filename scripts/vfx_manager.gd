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
