extends Node
class_name FighterState

var fighter: CharacterBody2D
var state_machine: StateMachine

func enter(_msg: Dictionary) -> void:
	pass

func exit() -> void:
	pass

func state_process(_delta: float) -> void:
	pass

func state_physics_process(_delta: float) -> void:
	pass
