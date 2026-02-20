extends Node2D
class_name NodeEnemy
var stats: EnemyDB.EnemyData = EnemyDB.get_enemy("badboy")

	
func setup_enemy(data: EnemyDB.EnemyData) -> void:
	stats = data
	print("I am enemy: ", data.name)
	
	
	var texture: Texture2D = load(stats.texture_path)
	var sprite := NodeMain.build_sprite_animation(texture, 128, 128, 7, "idle")
	sprite.flip_h = true
	add_child(sprite)





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$enemybody.input_pickable = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func damage_melee(amount: int) -> void:
	print("enemy hp before: ", stats.health)
	stats.health -= amount
	print("enemy hp after: ", stats.health)

func _on_enemybody_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true: #if left mouse down
			print("trying to send event")
			EventBus.enemy_clicked.emit(self)
