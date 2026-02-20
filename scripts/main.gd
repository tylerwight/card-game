extends Node
class_name NodeMain


# next: discard, exhaust
# card end phase
# debug UI, player, enemy, card info, etc.

func hide_ui() -> void:
	var UI := get_tree().get_first_node_in_group("UI")
	UI.hide_all()


func create_encounter(player_manager: Node2D, enemies: Array[EnemyDB.EnemyData], title: String):
	var scene_encounter = preload("res://scenes/encounter.tscn")
	var scene_player = preload("res://scenes/player.tscn")
	var encounter = scene_encounter.instantiate()
	
	encounter.title = title
	encounter.player_deck = player_manager.deck
	encounter.player = scene_player.instantiate()
	
	
	for enemy in enemies:
		encounter.enemies_data.push_back(enemy)
		
		
	get_node("/root").add_child(encounter)
	encounter.world_root.add_child(encounter.player)

func _ready() -> void:
	pass
	


func _process(delta: float) -> void:
	pass

	
static func build_sprite_animation(texture: Texture2D, frame_w: int, frame_h: int, frame_count: int, anim_name: String) -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	var frames := SpriteFrames.new()

	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, true)

	for i in frame_count:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * frame_w, 0, frame_w, frame_h)
		frames.add_frame(anim_name, atlas)

	sprite.sprite_frames = frames
	sprite.play(anim_name)
	return sprite
