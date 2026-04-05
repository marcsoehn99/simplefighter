extends Control

@onready var sfx_slider: HSlider = $VBoxContainer/SFXRow/SFXSlider
@onready var rounds_label: Label = $VBoxContainer/RoundsRow/RoundsValue
@onready var timer_label: Label = $VBoxContainer/TimerRow/TimerValue

var round_options := [1, 2, 3]
var timer_options := [60, 99, -1]
var round_index: int = 1
var timer_index: int = 1

func _ready() -> void:
	sfx_slider.value = GameSettings.sfx_volume * 100.0
	round_index = round_options.find(GameSettings.rounds_to_win)
	if round_index == -1:
		round_index = 1
	timer_index = timer_options.find(GameSettings.round_timer)
	if timer_index == -1:
		timer_index = 1
	_update_labels()
	sfx_slider.grab_focus()

func _update_labels() -> void:
	rounds_label.text = str(round_options[round_index])
	if timer_options[timer_index] == -1:
		timer_label.text = "INF"
	else:
		timer_label.text = str(timer_options[timer_index])

func _on_sfx_slider_value_changed(value: float) -> void:
	GameSettings.sfx_volume = value / 100.0
	GameSettings.apply_audio_settings()

func _on_rounds_left_pressed() -> void:
	round_index = (round_index - 1 + round_options.size()) % round_options.size()
	GameSettings.rounds_to_win = round_options[round_index]
	AudioManager.play("menu_select")
	_update_labels()

func _on_rounds_right_pressed() -> void:
	round_index = (round_index + 1) % round_options.size()
	GameSettings.rounds_to_win = round_options[round_index]
	AudioManager.play("menu_select")
	_update_labels()

func _on_timer_left_pressed() -> void:
	timer_index = (timer_index - 1 + timer_options.size()) % timer_options.size()
	GameSettings.round_timer = timer_options[timer_index]
	AudioManager.play("menu_select")
	_update_labels()

func _on_timer_right_pressed() -> void:
	timer_index = (timer_index + 1) % timer_options.size()
	GameSettings.round_timer = timer_options[timer_index]
	AudioManager.play("menu_select")
	_update_labels()

func _on_back_pressed() -> void:
	AudioManager.play("menu_select")
	get_tree().change_scene_to_file("res://scenes/main.tscn")
