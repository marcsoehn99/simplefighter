extends FighterState

func enter(_msg: Dictionary) -> void:
	fighter.velocity.x = 0
	fighter.play_anim("crouch")

func exit() -> void:
	pass

func state_physics_process(delta: float) -> void:
	fighter.apply_gravity(delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0, 800 * delta)
	fighter.move_and_slide()

	if not fighter.can_act:
		return

	if fighter.check_super_input():
		fighter.use_super()
		return

	var special = fighter.check_special_input()
	if special != "":
		state_machine.transition_to("attack", {"attack_name": special})
		return

	if fighter.is_input_just_pressed("lp"):
		state_machine.transition_to("attack", {"attack_name": "crouch_lp"})
		return
	if fighter.is_input_just_pressed("hp"):
		state_machine.transition_to("attack", {"attack_name": "crouch_hp"})
		return
	if fighter.is_input_just_pressed("lk"):
		state_machine.transition_to("attack", {"attack_name": "crouch_lk"})
		return
	if fighter.is_input_just_pressed("hk"):
		state_machine.transition_to("attack", {"attack_name": "crouch_hk"})
		return

	if not fighter.is_input_pressed("down"):
		state_machine.transition_to("idle")
		return
