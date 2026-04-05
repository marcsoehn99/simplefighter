extends Node

# Animation definitions: name -> {file, fps, loop}
# Frame count is auto-detected from image width / FRAME_HEIGHT
const FRAME_HEIGHT := 92

const ANIMS := {
	"idle":         {"file": "idle.png",         "fps": 8.0,  "loop": true},
	"walk":         {"file": "walk.png",         "fps": 10.0, "loop": true},
	"jump":         {"file": "jump.png",         "fps": 12.0, "loop": false},
	"crouch":       {"file": "crouch.png",       "fps": 10.0, "loop": false},
	"stand_lp":     {"file": "stand_lp.png",     "fps": 15.0, "loop": false},
	"stand_hp":     {"file": "stand_hp.png",     "fps": 12.0, "loop": false},
	"stand_lk":     {"file": "stand_lk.png",     "fps": 15.0, "loop": false},
	"stand_hk":     {"file": "stand_hk.png",     "fps": 12.0, "loop": false},
	"fireball":     {"file": "fireball.png",     "fps": 12.0, "loop": false},
	"dragon_punch": {"file": "dragon_punch.png", "fps": 15.0, "loop": false},
	"crouch_hk":    {"file": "crouch_hk.png",    "fps": 12.0, "loop": false},
	"hit_stun":     {"file": "hit_stun.png",     "fps": 10.0, "loop": false},
	"ko":           {"file": "ko.png",           "fps": 8.0,  "loop": false},
}

var p1_sprite_frames: SpriteFrames
var p2_sprite_frames: SpriteFrames

func _ready() -> void:
	p1_sprite_frames = _load_sprite_frames("res://assets/p1/sheets/")
	p2_sprite_frames = _load_sprite_frames("res://assets/p2/sheets/")

func _load_sprite_frames(base_path: String) -> SpriteFrames:
	var sf = SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")

	for anim_name in ANIMS:
		var info: Dictionary = ANIMS[anim_name]
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, info["fps"])
		sf.set_animation_loop(anim_name, info["loop"])

		var texture: Texture2D = load(base_path + info["file"])
		if texture == null:
			push_warning("Could not load: " + base_path + info["file"])
			continue

		var frame_w: int = FRAME_HEIGHT
		var frame_h: int = texture.get_height()
		# Auto-detect frame count from width
		var frame_count: int = maxi(1, texture.get_width() / frame_w)

		for i in frame_count:
			var atlas = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * frame_w, 0, frame_w, frame_h)
			sf.add_frame(anim_name, atlas)

	return sf
