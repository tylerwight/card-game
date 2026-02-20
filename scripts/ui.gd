extends Control


func hide_all() -> void:
	for child in get_children():
		child.hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("UI")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mainmenu_start_game() -> void:
	Main.hide_ui()
	var scene_level_select = preload("res://scenes/levelselect.tscn")
	var level_select = scene_level_select.instantiate()
	level_select.test = 2
	add_child(level_select)
