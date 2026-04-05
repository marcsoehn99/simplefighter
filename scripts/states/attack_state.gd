extends FighterState

var attack_data: AttackData
var frame_counter: int = 0
var is_airborne: bool = false

# Map attack_data names to sprite animation names
const ANIM_MAP := {
	"stand_lp": "stand_lp",
	"stand_hp": "stand_hp",
	"stand_lk": "stand_lk",
	"stand_hk": "stand_hk",
	"crouch_lp": "stand_lp",
	"crouch_hp": "stand_hp",
	"crouch_lk": "stand_lk",
	"crouch_hk": "crouch_hk",
	"jump_lp": "stand_lp",
	"jump_hp": "stand_hp",
	"jump_lk": "stand_lk",
	"jump_hk": "stand_hk",
	"fireball": "fireball",
	"dragon_punch": "dragon_punch",
	"tornado_kick": "tornado_kick",
	"sumo_charge": "sumo_charge",
	"palm_strike": "palm_strike",
	"ground_stomp": "ground_stomp",
	"clothesline": "clothesline",
	"body_splash": "body_splash",
	"gorilla_press": "gorilla_press",
	"sword_wave": "sword_wave",
	"rising_slash": "rising_slash",
	"whirlwind_slash": "whirlwind_slash",
	"rasengan": "rasengan",
	"shadow_clone": "shadow_clone",
	"rasenshuriken": "rasenshuriken",
	"super_attack": "super_attack",
}

func enter(msg: Dictionary) -> void:
	var attack_name: String = msg.get("attack_name", "stand_lp")
	is_airborne = msg.get("airborne", false)
	frame_counter = 0
	fighter.hits_landed_this_attack.clear()

	attack_data = fighter.get_attack_data(attack_name)
	if attack_data == null:
		attack_data = AttackData.new()
		attack_data.attack_name = attack_name
		attack_data.damage = 5
		attack_data.startup_frames = 3
		attack_data.active_frames = 3
		attack_data.recovery_frames = 8

	# Per-special movement velocities
	var dir_x = 1.0 if fighter.facing_right else -1.0
	if attack_data.is_special:
		match attack_data.attack_name:
			"dragon_punch":
				fighter.velocity.y = -600
				fighter.velocity.x = dir_x * 150
			"tornado_kick":
				fighter.velocity.x = dir_x * 350
			"sumo_charge":
				fighter.velocity.x = dir_x * 500
			"clothesline":
				fighter.velocity.x = dir_x * 400
			"body_splash":
				fighter.velocity.x = dir_x * 200
				fighter.velocity.y = -500
			"gorilla_press":
				fighter.velocity.y = -500
			"rising_slash":
				fighter.velocity.y = -550
				fighter.velocity.x = dir_x * 100
			"shadow_clone":
				fighter.velocity.x = dir_x * 450
			"super_attack":
				fighter.velocity.x = dir_x * 300
				VFXManager.screen_shake(8.0, 0.3)

	# Play matching sprite animation
	var anim_name = ANIM_MAP.get(attack_name, "stand_lp")
	fighter.play_anim(anim_name)

func exit() -> void:
	fighter.hitbox.deactivate()
	fighter.hits_landed_this_attack.clear()
	attack_data = null

func state_physics_process(delta: float) -> void:
	fighter.apply_gravity(delta)

	if not is_airborne and fighter.is_on_floor():
		fighter.velocity.x = move_toward(fighter.velocity.x, 0, 600 * delta)

	fighter.move_and_slide()
	frame_counter += 1

	if frame_counter == attack_data.active_start:
		AudioManager.play_attack_sound(attack_data.attack_name)
		if attack_data.is_projectile:
			var spd = attack_data.projectile_speed
			fighter.spawn_projectile(spd)
		else:
			fighter.hitbox.activate(attack_data)
		# Attacker gains meter when hitting
		if not attack_data.is_projectile:
			fighter.add_meter(attack_data.damage)

	if frame_counter == attack_data.active_end:
		fighter.hitbox.deactivate()

	if frame_counter >= attack_data.total_frames:
		if is_airborne and not fighter.is_on_floor():
			state_machine.transition_to("jump", {"from_air_attack": true})
		else:
			state_machine.transition_to("idle")
