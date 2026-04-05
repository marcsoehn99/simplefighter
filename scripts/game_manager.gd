extends Node2D

enum Phase { INTRO, FIGHT, KO, ROUND_END, MATCH_END }

var phase: Phase = Phase.INTRO
var round_number: int = 1
var p1_wins: int = 0
var p2_wins: int = 0
var round_timer: float = 99.0
var phase_timer: float = 0.0

const P1_START_POS := Vector2(350, 610)
const P2_START_POS := Vector2(930, 610)

@onready var fighter1: CharacterBody2D = $Fighter1
@onready var fighter2: CharacterBody2D = $Fighter2
@onready var hud = $HUD
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	VFXManager.register_camera(camera)

	# Load stage background
	var bg_path = "res://assets/stages/" + GameSettings.stage_id + "/background.png"
	if ResourceLoader.exists(bg_path):
		var bg_texture = load(bg_path)
		var bg_sprite = $Stage/Background
		if bg_sprite and bg_texture:
			bg_sprite.texture = bg_texture

	fighter1.opponent = fighter2
	fighter2.opponent = fighter1
	fighter1.fighter_ko.connect(_on_fighter_ko)
	fighter2.fighter_ko.connect(_on_fighter_ko)
	fighter1.health_changed.connect(func(h): hud.update_health(1, h))
	fighter2.health_changed.connect(func(h): hud.update_health(2, h))
	_start_round()

func _start_round() -> void:
	phase = Phase.INTRO
	round_timer = float(GameSettings.round_timer)
	fighter1.reset_fighter(P1_START_POS)
	fighter2.reset_fighter(P2_START_POS)
	fighter1.can_act = false
	fighter2.can_act = false
	hud.update_timer(GameSettings.round_timer)
	hud.update_round_indicators(p1_wins, p2_wins)
	hud.show_splash("ROUND " + str(round_number))
	var round_sound = "announce_round_" + str(clampi(round_number, 1, 3))
	AudioManager.play(round_sound)
	phase_timer = 2.0

func _physics_process(delta: float) -> void:
	match phase:
		Phase.INTRO:
			phase_timer -= delta
			if phase_timer <= 0.5 and phase_timer + delta > 0.5:
				hud.show_splash("FIGHT!")
				AudioManager.play("announce_fight")
			if phase_timer <= 0:
				phase = Phase.FIGHT
				fighter1.can_act = true
				fighter2.can_act = true
				hud.hide_splash()

		Phase.FIGHT:
			round_timer -= delta
			hud.update_timer(ceili(round_timer))
			if round_timer <= 0:
				round_timer = 0
				hud.update_timer(0)
				_time_over()

		Phase.KO:
			phase_timer -= delta
			if phase_timer <= 0:
				_end_round()

		Phase.ROUND_END:
			phase_timer -= delta
			if phase_timer <= 0:
				if p1_wins >= GameSettings.rounds_to_win or p2_wins >= GameSettings.rounds_to_win:
					phase = Phase.MATCH_END
					var winner = "PLAYER 1" if p1_wins >= GameSettings.rounds_to_win else "PLAYER 2"
					hud.show_splash(winner + " WINS!")
					if p1_wins >= GameSettings.rounds_to_win:
						AudioManager.play("announce_p1_wins")
					else:
						AudioManager.play("announce_p2_wins")
					var winner_fighter = fighter1 if p1_wins >= GameSettings.rounds_to_win else fighter2
					if winner_fighter.health >= 100:
						AudioManager.play("announce_perfect")
					phase_timer = 3.0
				else:
					round_number += 1
					_start_round()

		Phase.MATCH_END:
			phase_timer -= delta
			if phase_timer <= 0:
				_return_to_title()

func _on_fighter_ko(ko_fighter: CharacterBody2D) -> void:
	if phase != Phase.FIGHT:
		return
	phase = Phase.KO
	fighter1.can_act = false
	fighter2.can_act = false
	hud.show_splash("K.O.!")
	AudioManager.play("announce_ko")
	phase_timer = 2.0

	if ko_fighter == fighter1:
		p2_wins += 1
	else:
		p1_wins += 1

func _time_over() -> void:
	phase = Phase.KO
	fighter1.can_act = false
	fighter2.can_act = false
	AudioManager.play("announce_time_over")

	if fighter1.health > fighter2.health:
		p1_wins += 1
		hud.show_splash("TIME! P1 WINS")
	elif fighter2.health > fighter1.health:
		p2_wins += 1
		hud.show_splash("TIME! P2 WINS")
	else:
		hud.show_splash("TIME! DRAW")
	phase_timer = 2.0

func _end_round() -> void:
	phase = Phase.ROUND_END
	hud.update_round_indicators(p1_wins, p2_wins)
	phase_timer = 1.5

func _return_to_title() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
