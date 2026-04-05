extends Node

var sounds: Dictionary = {}

const SOUND_FILES := {
	"punch_light": "res://assets/sounds/punch_light.mp3",
	"punch_heavy": "res://assets/sounds/punch_heavy.mp3",
	"kick_light": "res://assets/sounds/kick_light.mp3",
	"kick_heavy": "res://assets/sounds/kick_heavy.mp3",
	"block": "res://assets/sounds/block.mp3",
	"fireball": "res://assets/sounds/fireball.mp3",
	"dragon_punch": "res://assets/sounds/dragon_punch.mp3",
	"hit_stun": "res://assets/sounds/hit_stun.mp3",
	"ko": "res://assets/sounds/ko.mp3",
	"ko_announce": "res://assets/sounds/ko_announce.mp3",
	"round_start": "res://assets/sounds/round_start.mp3",
	"time_over": "res://assets/sounds/time_over.mp3",
	"victory": "res://assets/sounds/victory.mp3",
	"projectile_hit": "res://assets/sounds/projectile_hit.mp3",
	"menu_select": "res://assets/sounds/menu_select.mp3",
}

func _ready() -> void:
	for key in SOUND_FILES:
		var stream = load(SOUND_FILES[key])
		if stream:
			sounds[key] = stream

func play(sound_name: String) -> void:
	if sound_name not in sounds:
		return
	var player = AudioStreamPlayer.new()
	player.stream = sounds[sound_name]
	player.bus = "Master"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_attack_sound(attack_name: String) -> void:
	match attack_name:
		"stand_lp", "crouch_lp", "jump_lp":
			play("punch_light")
		"stand_hp", "crouch_hp", "jump_hp":
			play("punch_heavy")
		"stand_lk", "crouch_lk", "jump_lk":
			play("kick_light")
		"stand_hk", "crouch_hk", "jump_hk":
			play("kick_heavy")
		"fireball":
			play("fireball")
		"dragon_punch":
			play("dragon_punch")
