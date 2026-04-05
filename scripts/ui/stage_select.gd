extends Control

const STAGES := ["dojo", "rooftop", "temple"]
const STAGE_NAMES := {"dojo": "DOJO", "rooftop": "ROOFTOP", "temple": "TEMPLE"}

var selected_index: int = 0

@onready var stage_name_label: Label = $VBoxContainer/StageName
@onready var preview: TextureRect = $VBoxContainer/Preview

func _ready() -> void:
	AudioManager.play("announce_choose_stage")
	_update_selection()

func _update_selection() -> void:
	var stage_id = STAGES[selected_index]
	stage_name_label.text = STAGE_NAMES[stage_id]

	var bg_path = "res://assets/stages/" + stage_id + "/background.png"
	if ResourceLoader.exists(bg_path):
		preview.texture = load(bg_path)
	else:
		preview.texture = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_left") or event.is_action_pressed("p2_left"):
		selected_index = (selected_index - 1 + STAGES.size()) % STAGES.size()
		AudioManager.play("menu_select")
		_update_selection()
	elif event.is_action_pressed("p1_right") or event.is_action_pressed("p2_right"):
		selected_index = (selected_index + 1) % STAGES.size()
		AudioManager.play("menu_select")
		_update_selection()
	elif event.is_action_pressed("p1_lp") or event.is_action_pressed("p2_lp"):
		GameSettings.stage_id = STAGES[selected_index]
		AudioManager.play("menu_select")
		get_tree().change_scene_to_file("res://scenes/game.tscn")
