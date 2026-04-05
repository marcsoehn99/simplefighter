extends Control

func _ready() -> void:
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed() -> void:
	AudioManager.play("menu_select")
	get_tree().change_scene_to_file("res://scenes/ui/character_select.tscn")

func _on_options_button_pressed() -> void:
	AudioManager.play("menu_select")
	get_tree().change_scene_to_file("res://scenes/ui/options.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
