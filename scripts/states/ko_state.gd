extends FighterState

func enter(_msg: Dictionary) -> void:
	fighter.velocity = Vector2(-200 if fighter.facing_right else 200, -400)
	AudioManager.play("ko")
	fighter.sprite.modulate = Color(0.5, 0.2, 0.2, 1)
	fighter.play_anim("ko")
	VFXManager.screen_flash(Color.WHITE, 0.1)
	VFXManager.screen_shake(10.0, 0.4)
	VFXManager.slowmo(0.3, 0.5)

func state_physics_process(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0, 200 * delta)
	fighter.move_and_slide()

	if fighter.is_on_floor() and fighter.velocity.y >= 0:
		fighter.velocity = Vector2.ZERO
		# Lay character flat on ground — fall backward away from opponent
		fighter.sprite.rotation_degrees = 90 if fighter.facing_right else -90
		# Sprite is near floor level; small offset so body rests on surface
		fighter.sprite.position = Vector2(0, -30)
