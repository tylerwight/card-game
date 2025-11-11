extends Control

var test: int = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_1_pressed() -> void:
	var scene_encounter = preload("res://scenes/encounter.tscn")
	var encounter = scene_encounter.instantiate()
	encounter.title = "Level 1"
	get_node("/root").add_child(encounter)
	#get_tree().root.add_child(encounter)
	hide()
	pass # Replace with function body.
