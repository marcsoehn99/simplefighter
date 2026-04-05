extends FighterState

func enter(_msg: Dictionary) -> void:
	fighter.play_anim("walk")

func state_physics_process(delta: float) -> void:
	fighter.apply_gravity(delta)

	if not fighter.can_act:
		fighter.velocity.x = 0
		fighter.move_and_slide()
		return

	if fighter.check_super_input():
		fighter.use_super()
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

	var dir := 0.0
	if fighter.is_input_pressed("left"):
		dir = -1.0
	elif fighter.is_input_pressed("right"):
		dir = 1.0

	if dir == 0.0:
		state_machine.transition_to("idle")
		return

	fighter.velocity.x = dir * fighter.MOVE_SPEED
	fighter.move_and_slide()
