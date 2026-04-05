extends Node
class_name InputBuffer

const BUFFER_SIZE: int = 20
const QCF_WINDOW: int = 15
const DP_WINDOW: int = 15

var buffer: Array[int] = []
var fighter: CharacterBody2D

enum Dir {
	NONE = 0,
	RIGHT = 1,
	LEFT = 2,
	DOWN = 4,
	UP = 8,
	DOWN_RIGHT = 5,
	DOWN_LEFT = 6,
}

func _ready() -> void:
	fighter = get_parent()
	for i in BUFFER_SIZE:
		buffer.append(Dir.NONE)

func record_direction(dir: int) -> void:
	buffer.push_back(dir)
	if buffer.size() > BUFFER_SIZE:
		buffer.pop_front()

func get_current_direction() -> int:
	var dir: int = Dir.NONE
	if fighter.is_input_pressed("right"):
		dir |= Dir.RIGHT
	elif fighter.is_input_pressed("left"):
		dir |= Dir.LEFT
	if fighter.is_input_pressed("down"):
		dir |= Dir.DOWN
	elif fighter.is_input_pressed("up"):
		dir |= Dir.UP
	return dir

func update() -> void:
	record_direction(get_current_direction())

func check_qcf() -> bool:
	var facing_right: bool = fighter.facing_right
	var forward = Dir.RIGHT if facing_right else Dir.LEFT
	var down_forward = Dir.DOWN_RIGHT if facing_right else Dir.DOWN_LEFT

	var recent = buffer.slice(maxi(0, buffer.size() - QCF_WINDOW))

	var found_down := false
	var found_down_forward := false

	for i in recent.size():
		var d = recent[i]
		if not found_down:
			if d & Dir.DOWN and not (d & forward):
				found_down = true
		elif not found_down_forward:
			if d == down_forward or (d & Dir.DOWN and d & forward):
				found_down_forward = true
		else:
			if d == forward or d & forward:
				return true
	return false

func check_dp() -> bool:
	# Down, Down, Back, Back + Punch
	var facing_right: bool = fighter.facing_right
	var back = Dir.LEFT if facing_right else Dir.RIGHT

	var recent = buffer.slice(maxi(0, buffer.size() - DP_WINDOW))

	var found_down1 := false
	var found_down2 := false
	var found_back1 := false

	for i in recent.size():
		var d = recent[i]
		if not found_down1:
			if d & Dir.DOWN:
				found_down1 = true
		elif not found_down2:
			if d & Dir.DOWN:
				found_down2 = true
			elif not (d & Dir.DOWN):
				found_down1 = false
				found_down2 = false
		elif not found_back1:
			if d == back:
				found_back1 = true
		else:
			if d == back:
				return true
	return false
