extends Control

signal start_game()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	start_game.emit()
	
	
	#get_tree().root.print_tree()
	#ui.hide_all() # also doesn't work
