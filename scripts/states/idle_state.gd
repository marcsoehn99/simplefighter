extends FighterState

func enter(_msg: Dictionary) -> void:
	fighter.play_anim("idle")

func state_physics_process(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0, 800 * delta)
	fighter.move_and_slide()

	if not fighter.can_act:
		return

	var special = fighter.check_special_input()
	if special != "":
		state_machine.transition_to("attack", {"attack_name": special})
		return

	if fighter.is_input_just_pressed("lp"):
		state_machine.transition_to("attack", {"attack_name": "stand_lp"})
		return
	if fighter.is_input_just_pressed("hp"):
		state_machine.transition_to("attack", {"attack_name": "stand_hp"})
		return
	if fighter.is_input_just_pressed("lk"):
		state_machine.transition_to("attack", {"attack_name": "stand_lk"})
		return
	if fighter.is_input_just_pressed("hk"):
		state_machine.transition_to("attack", {"attack_name": "stand_hk"})
		return

	if fighter.is_input_pressed("down") and fighter.is_on_floor():
		state_machine.transition_to("crouch")
		return

	if fighter.is_input_just_pressed("up") and fighter.is_on_floor():
		state_machine.transition_to("jump")
		return

	if fighter.is_input_pressed("left") or fighter.is_input_pressed("right"):
		state_machine.transition_to("walk")
		return
