extends CanvasLayer

@onready var p1_health_bar: ProgressBar = $TopBar/P1HealthBar
@onready var p2_health_bar: ProgressBar = $TopBar/P2HealthBar
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var splash_label: Label = $SplashLabel
@onready var p1_rounds: HBoxContainer = $TopBar/P1Rounds
@onready var p2_rounds: HBoxContainer = $TopBar/P2Rounds

func _ready() -> void:
	splash_label.visible = false

func update_health(player: int, health: int) -> void:
	if player == 1:
		p1_health_bar.value = health
	else:
		p2_health_bar.value = health

func update_timer(time: int) -> void:
	timer_label.text = str(clampi(time, 0, 99))

func show_splash(text: String) -> void:
	splash_label.text = text
	splash_label.visible = true

func hide_splash() -> void:
	splash_label.visible = false

func update_round_indicators(p1_wins: int, p2_wins: int) -> void:
	for i in p1_rounds.get_child_count():
		var indicator = p1_rounds.get_child(i)
		if indicator is ColorRect:
			indicator.color = Color.YELLOW if i < p1_wins else Color(0.3, 0.3, 0.3)
	for i in p2_rounds.get_child_count():
		var indicator = p2_rounds.get_child(i)
		if indicator is ColorRect:
			indicator.color = Color.YELLOW if i < p2_wins else Color(0.3, 0.3, 0.3)
