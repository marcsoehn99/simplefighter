extends Control

const FIGHTERS := ["fighter_01", "fighter_02", "fighter_03", "fighter_04", "fighter_05", "fighter_06", "fighter_07"]
const FIGHTER_NAMES := {
	"fighter_01": "BLITZ",
	"fighter_02": "RYUKEN",
	"fighter_03": "VENOM",
	"fighter_04": "TETSUO",
	"fighter_05": "TITAN",
	"fighter_06": "KENSHI",
	"fighter_07": "NARUTO",
}

var p1_index: int = 0
var p2_index: int = 0
var p1_ready: bool = false
var p2_ready: bool = false

@onready var p1_name_label: Label = $HBoxContainer/P1Panel/P1Name
@onready var p2_name_label: Label = $HBoxContainer/P2Panel/P2Name
@onready var p1_sprite: AnimatedSprite2D = $HBoxContainer/P1Panel/P1PreviewCenter/P1Preview
@onready var p2_sprite: AnimatedSprite2D = $HBoxContainer/P2Panel/P2PreviewCenter/P2Preview
@onready var p1_ready_label: Label = $HBoxContainer/P1Panel/P1Ready
@onready var p2_ready_label: Label = $HBoxContainer/P2Panel/P2Ready
@onready var ai_toggle: CheckButton = $HBoxContainer/P2Panel/AIToggle

func _ready() -> void:
	AudioManager.play("announce_select_fighter")
	ai_toggle.button_pressed = GameSettings.p2_is_ai
	_update_selection()

func _update_selection() -> void:
	p1_name_label.text = FIGHTER_NAMES[FIGHTERS[p1_index]]
	p2_name_label.text = FIGHTER_NAMES[FIGHTERS[p2_index]]

	var p1_frames = SpriteLoader.load_fighter_frames(FIGHTERS[p1_index])
	if p1_frames and p1_frames.has_animation("idle"):
		p1_sprite.sprite_frames = p1_frames
		p1_sprite.play("idle")
		var p1_h = SpriteLoader.get_frame_height(FIGHTERS[p1_index])
		var p1_scale = 3.0 * (92.0 / p1_h)
		p1_sprite.scale = Vector2(p1_scale, p1_scale)

	var p2_frames = SpriteLoader.load_fighter_frames(FIGHTERS[p2_index])
	if p2_frames and p2_frames.has_animation("idle"):
		p2_sprite.sprite_frames = p2_frames
		p2_sprite.play("idle")
		p2_sprite.flip_h = true
		var p2_h = SpriteLoader.get_frame_height(FIGHTERS[p2_index])
		var p2_scale = 3.0 * (92.0 / p2_h)
		p2_sprite.scale = Vector2(p2_scale, p2_scale)

	p1_ready_label.text = "READY!" if p1_ready else ""
	p2_ready_label.text = "READY!" if p2_ready else ""

func _input(event: InputEvent) -> void:
	if not p1_ready:
		if event.is_action_pressed("p1_left"):
			p1_index = (p1_index - 1 + FIGHTERS.size()) % FIGHTERS.size()
			AudioManager.play("menu_select")
			_update_selection()
		elif event.is_action_pressed("p1_right"):
			p1_index = (p1_index + 1) % FIGHTERS.size()
			AudioManager.play("menu_select")
			_update_selection()
		elif event.is_action_pressed("p1_lp"):
			p1_ready = true
			AudioManager.play("menu_select")
			_update_selection()
			_check_both_ready()

	if not p2_ready:
		if event.is_action_pressed("p2_left"):
			p2_index = (p2_index - 1 + FIGHTERS.size()) % FIGHTERS.size()
			AudioManager.play("menu_select")
			_update_selection()
		elif event.is_action_pressed("p2_right"):
			p2_index = (p2_index + 1) % FIGHTERS.size()
			AudioManager.play("menu_select")
			_update_selection()
		elif event.is_action_pressed("p2_lp"):
			p2_ready = true
			AudioManager.play("menu_select")
			_update_selection()
			_check_both_ready()

func _check_both_ready() -> void:
	if p1_ready and p2_ready:
		GameSettings.p1_fighter = FIGHTERS[p1_index]
		GameSettings.p2_fighter = FIGHTERS[p2_index]
		GameSettings.p2_is_ai = ai_toggle.button_pressed
		get_tree().create_timer(0.5).timeout.connect(_go_to_stage_select)

func _go_to_stage_select() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/stage_select.tscn")
