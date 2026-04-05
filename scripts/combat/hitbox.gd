extends Area2D
class_name Hitbox

var attack_data: AttackData
var owner_fighter: CharacterBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var visual: ColorRect = $Visual

func _ready() -> void:
	owner_fighter = get_parent()
	monitoring = false
	monitorable = false
	collision.disabled = true
	visual.visible = false
	area_entered.connect(_on_area_entered)

func activate(data: AttackData) -> void:
	attack_data = data
	var offset = data.hitbox_offset
	if not owner_fighter.facing_right:
		offset.x = -offset.x

	collision.position = offset
	visual.position = offset - data.hitbox_size / 2.0
	visual.size = data.hitbox_size

	var shape = RectangleShape2D.new()
	shape.size = data.hitbox_size
	collision.shape = shape
	collision.disabled = false
	monitoring = true
	visual.visible = true

func deactivate() -> void:
	monitoring = false
	collision.disabled = true
	visual.visible = false
	attack_data = null

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and attack_data:
		var target = area.owner_fighter
		if target != owner_fighter and target not in owner_fighter.hits_landed_this_attack:
			owner_fighter.hits_landed_this_attack.append(target)
			var kb = attack_data.knockback
			if not owner_fighter.facing_right:
				kb.x = -kb.x
			target.take_damage(attack_data.damage, kb, attack_data.stun_frames, attack_data.chip_damage)
