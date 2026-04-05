extends Area2D
class_name Hurtbox

var owner_fighter: CharacterBody2D

func _ready() -> void:
	owner_fighter = get_parent()
	monitoring = false
	monitorable = true
