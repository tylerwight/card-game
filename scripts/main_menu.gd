extends Control

signal start_game()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for card_id in CardDB.cards_global:
		#CardDB.cards_global[card_id].print_self()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.TITLE_MUSIC)
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
