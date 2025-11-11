extends Node2D

signal card_played(card: CardDb.CardData)

var card_info: CardDb.CardData = CardDb.get_card("attack_basic")
var deck_hand: Node2D

func _ready() -> void:
	$cardbody.input_pickable = true
	var sprite:= Sprite2D.new()
	deck_hand = get_node("/root/Encounter/deck_hand")
	if deck_hand:
		print("found the deck/hand")
	#sprite.texture = load("res://assets/test_card.png")
	#add_child(sprite)


func _process(delta: float) -> void:
	pass



func _on_cardbody_mouse_entered() -> void:
	pass # Replace with function body.


func _on_cardbody_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("is mouse button")
		print(event)
		if event.button_index == 1 and event.pressed == true:
			card_played.emit(card_info)
	
	
