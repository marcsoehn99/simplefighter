extends FighterState

var stun_timer: int = 0
var stun_duration: int = 8

func enter(msg: Dictionary) -> void:
	stun_duration = msg.get("stun_frames", 8)
	var knockback: Vector2 = msg.get("knockback", Vector2(60, 0))
	stun_timer = 0
	fighter.velocity = knockback
	AudioManager.play("block")
	fighter.sprite.modulate = Color(0.5, 0.5, 1.0, 1)
	fighter.play_anim("hit_stun")

func exit() -> void:
	fighter.sprite.modulate = Color.WHITE

func state_physics_process(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0, 600 * delta)
	fighter.move_and_slide()

	stun_timer += 1
	if stun_timer >= stun_duration and fighter.is_on_floor():
		state_machine.transition_to("idle")
