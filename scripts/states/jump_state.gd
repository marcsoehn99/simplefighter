extends FighterState

var has_attacked: bool = false

func enter(msg: Dictionary) -> void:
	var from_air_attack: bool = msg.get("from_air_attack", false)

	if not from_air_attack:
		# Fresh jump - apply jump velocity
		fighter.velocity.y = fighter.JUMP_VELOCITY
		has_attacked = false
		fighter.play_anim("jump")

		var dir := 0.0
		if fighter.is_input_pressed("left"):
			dir = -1.0
		elif fighter.is_input_pressed("right"):
			dir = 1.0
		fighter.velocity.x = dir * fighter.MOVE_SPEED * 0.8
	else:
		# Returning from air attack - don't re-jump, keep falling
		has_attacked = true
		fighter.play_anim("jump")

func state_physics_process(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.move_and_slide()

	if not fighter.can_act:
		return

	if not has_attacked:
		var special = fighter.check_special_input()
		if special == "dragon_punch":
			state_machine.transition_to("attack", {"attack_name": "dragon_punch", "airborne": true})
			has_attacked = true
			return

		if fighter.is_input_just_pressed("lp"):
			state_machine.transition_to("attack", {"attack_name": "jump_lp", "airborne": true})
			has_attacked = true
			return
		if fighter.is_input_just_pressed("hp"):
			state_machine.transition_to("attack", {"attack_name": "jump_hp", "airborne": true})
			has_attacked = true
			return
		if fighter.is_input_just_pressed("lk"):
			state_machine.transition_to("attack", {"attack_name": "jump_lk", "airborne": true})
			has_attacked = true
			return
		if fighter.is_input_just_pressed("hk"):
			state_machine.transition_to("attack", {"attack_name": "jump_hk", "airborne": true})
			has_attacked = true
			return

	if fighter.is_on_floor():
		state_machine.transition_to("idle")

func exit() -> void:
	has_attacked = false
