extends Node
class_name StateMachine

var current_state: FighterState
var states: Dictionary = {}

@onready var fighter: CharacterBody2D = get_parent()

func _ready() -> void:
	# Only register states here, don't start yet.
	# Fighter calls initialize() after its own _ready().
	for child in get_children():
		if child is FighterState:
			states[child.name.to_lower()] = child
			child.state_machine = self

func initialize(f: CharacterBody2D) -> void:
	fighter = f
	for state in states.values():
		state.fighter = fighter
	current_state = states.get("idle")
	if current_state:
		current_state.enter({})

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.state_physics_process(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.state_process(delta)

func transition_to(state_name: String, msg: Dictionary = {}) -> void:
	var new_state = states.get(state_name.to_lower())
	if new_state == null:
		push_warning("State not found: " + state_name)
		return
	if new_state == current_state:
		return
	current_state.exit()
	current_state = new_state
	current_state.enter(msg)
