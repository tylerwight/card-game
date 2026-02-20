extends Control

var test: int = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_1_pressed() -> void:
	var player_manager := get_tree().get_first_node_in_group("player_manager")
	
	var enemies: Array[EnemyDB.EnemyData]
	enemies.push_back(EnemyDB.get_enemy("badboy"))
	enemies.push_back(EnemyDB.get_enemy("goodboy"))
	Main.hide_ui()
	Main.create_encounter(player_manager, enemies, "Level 1")
