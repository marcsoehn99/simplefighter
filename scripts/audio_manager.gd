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
	"heavy_impact": "res://assets/sounds/heavy_impact.mp3",
	"energy_charge": "res://assets/sounds/energy_charge.mp3",
	"dp_whoosh": "res://assets/sounds/dp_whoosh.mp3",
	"announce_round_1": "res://assets/sounds/announcer/round_1.mp3",
	"announce_round_2": "res://assets/sounds/announcer/round_2.mp3",
	"announce_round_3": "res://assets/sounds/announcer/round_3.mp3",
	"announce_fight": "res://assets/sounds/announcer/fight.mp3",
	"announce_ko": "res://assets/sounds/announcer/ko.mp3",
	"announce_p1_wins": "res://assets/sounds/announcer/p1_wins.mp3",
	"announce_p2_wins": "res://assets/sounds/announcer/p2_wins.mp3",
	"announce_perfect": "res://assets/sounds/announcer/perfect.mp3",
	"announce_select_fighter": "res://assets/sounds/announcer/select_fighter.mp3",
	"announce_choose_stage": "res://assets/sounds/announcer/choose_stage.mp3",
	"announce_time_over": "res://assets/sounds/announcer/time_over.mp3",
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
