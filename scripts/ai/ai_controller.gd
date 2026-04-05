extends Node

var fighter: CharacterBody2D
var virtual_inputs: Dictionary = {}
var just_pressed: Dictionary = {}
var decision_timer: float = 0.0
var decision_interval: float = 0.15

func _ready() -> void:
	_clear_inputs()

func _clear_inputs() -> void:
	virtual_inputs = {
		"left": false, "right": false, "up": false, "down": false,
		"lp": false, "hp": false, "lk": false, "hk": false, "block": false
	}
	just_pressed = {
		"left": false, "right": false, "up": false, "down": false,
		"lp": false, "hp": false, "lk": false, "hk": false, "block": false
	}

func _physics_process(delta: float) -> void:
	# Clear just_pressed each frame
	for key in just_pressed:
		just_pressed[key] = false

	decision_timer -= delta
	if decision_timer <= 0:
		_make_decision()
		decision_timer = decision_interval + randf_range(-0.05, 0.1)

func _make_decision() -> void:
	var prev_inputs = virtual_inputs.duplicate()
	_clear_inputs()

	if fighter.opponent == null or fighter.is_knocked_out or not fighter.can_act:
		return

	var dist = abs(fighter.global_position.x - fighter.opponent.global_position.x)
	var opponent_attacking = fighter.opponent.state_machine.current_state.name.to_lower() == "attack"
	var roll = randf()

	if dist > 250:
		# Far - approach
		if fighter.facing_right:
			virtual_inputs["right"] = true
		else:
			virtual_inputs["left"] = true
		if roll < 0.08:
			virtual_inputs["up"] = true
			just_pressed["up"] = true
	elif dist > 100:
		# Mid range
		if opponent_attacking and roll < 0.4:
			# Block
			if fighter.facing_right:
				virtual_inputs["left"] = true
			else:
				virtual_inputs["right"] = true
			virtual_inputs["block"] = true
		elif roll < 0.15:
			# QCF motion for fireball - just press the attack, simplified
			virtual_inputs["hp"] = true
			just_pressed["hp"] = true
		elif roll < 0.35:
			virtual_inputs["hp"] = true
			just_pressed["hp"] = true
		elif roll < 0.55:
			virtual_inputs["hk"] = true
			just_pressed["hk"] = true
		elif roll < 0.7:
			if fighter.facing_right:
				virtual_inputs["right"] = true
			else:
				virtual_inputs["left"] = true
		elif roll < 0.8:
			virtual_inputs["up"] = true
			just_pressed["up"] = true
			if fighter.facing_right:
				virtual_inputs["right"] = true
			else:
				virtual_inputs["left"] = true
		else:
			# Walk back
			if fighter.facing_right:
				virtual_inputs["left"] = true
			else:
				virtual_inputs["right"] = true
	else:
		# Close range
		if opponent_attacking and roll < 0.5:
			if fighter.facing_right:
				virtual_inputs["left"] = true
			else:
				virtual_inputs["right"] = true
			virtual_inputs["block"] = true
		elif roll < 0.25:
			virtual_inputs["lp"] = true
			just_pressed["lp"] = true
		elif roll < 0.45:
			virtual_inputs["lk"] = true
			just_pressed["lk"] = true
		elif roll < 0.6:
			virtual_inputs["down"] = true
			virtual_inputs["lk"] = true
			just_pressed["lk"] = true
		elif roll < 0.75:
			virtual_inputs["hp"] = true
			just_pressed["hp"] = true
		else:
			# Back away
			if fighter.facing_right:
				virtual_inputs["left"] = true
			else:
				virtual_inputs["right"] = true

	# Mark newly pressed buttons as just_pressed
	for key in virtual_inputs:
		if virtual_inputs[key] and not prev_inputs.get(key, false):
			just_pressed[key] = true

func is_action_pressed(action: String) -> bool:
	return virtual_inputs.get(action, false)

func is_action_just_pressed(action: String) -> bool:
	return just_pressed.get(action, false)
