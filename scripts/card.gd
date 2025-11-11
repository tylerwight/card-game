extends Node2D


var card_info: CardDb.CardData = CardDb.get_card("attack_basic")
var deck_hand: Node2D
var encounter: Node2D

func _ready() -> void:
	$cardbody.input_pickable = true
	var sprite:= Sprite2D.new()
	deck_hand = get_node("/root/Encounter/UI/deck_hand")
	encounter = get_node("/root/Encounter")
	if not (deck_hand or encounter):
		print("couldn't find deck hand or encounter")
	
	#sprite.texture = load("res://assets/test_card.png")
	#add_child(sprite)


func _process(delta: float) -> void:
	pass
func _on_cardbody_mouse_entered() -> void:
	pass # Replace with function body.


func _on_cardbody_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true:
			print("trying to send event")
			EventBus.card_played.emit(card_info)
	
	
