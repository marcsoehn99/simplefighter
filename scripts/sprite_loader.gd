extends Node

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

var _cache: Dictionary = {}

func load_fighter_frames(fighter_id: String) -> SpriteFrames:
	if fighter_id in _cache:
		return _cache[fighter_id]

	var base_path = "res://assets/fighters/" + fighter_id + "/sheets/"
	var sf = _build_sprite_frames(base_path)
	_cache[fighter_id] = sf
	return sf

func _build_sprite_frames(base_path: String) -> SpriteFrames:
	var sf = SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")

	for anim_name in ANIMS:
		var info: Dictionary = ANIMS[anim_name]
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, info["fps"])
		sf.set_animation_loop(anim_name, info["loop"])

		var full_path = base_path + info["file"]
		if not ResourceLoader.exists(full_path):
			push_warning("Could not load: " + full_path)
			continue

		var texture: Texture2D = load(full_path)
		if texture == null:
			continue

		var frame_w: int = FRAME_HEIGHT
		var frame_h: int = texture.get_height()
		var frame_count: int = maxi(1, int(texture.get_width() / frame_w))

		for i in frame_count:
			var atlas = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * frame_w, 0, frame_w, frame_h)
			sf.add_frame(anim_name, atlas)

	return sf
