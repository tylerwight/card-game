extends Node2D

var stats: EnemyDb.EnemyData = EnemyDb.get_enemy("badboy")


func setup_enemy(data: EnemyDb.EnemyData) -> void:
	stats = data
	print("I am enemy: ", data.name)
	var sprite:= Sprite2D.new()
	sprite.texture = load(stats.texture_path)
	add_child(sprite)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
