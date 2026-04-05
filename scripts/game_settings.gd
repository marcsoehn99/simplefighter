extends Node

var p1_fighter: String = "fighter_01"
var p2_fighter: String = "fighter_01"
var stage_id: String = "dojo"
var p2_is_ai: bool = true
var rounds_to_win: int = 2
var round_timer: int = 99
var sfx_volume: float = 1.0
var music_volume: float = 1.0

func apply_audio_settings() -> void:
	var sfx_db = linear_to_db(sfx_volume) if sfx_volume > 0 else -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), sfx_db)
