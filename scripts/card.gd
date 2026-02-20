extends Node2D
class_name NodeCard

var card_info: CardDB.CardData = CardDB.get_card("attack_basic")
var deck_hand: Node2D
var encounter: Node2D


func setup_card(card: CardDB.CardData):
	card_info = card

func _ready() -> void:
	$cardbody.input_pickable = true
	var sprite:= Sprite2D.new()
	deck_hand = get_parent()
	encounter = get_parent().get_parent().get_parent()
	encounter = get_tree().get_first_node_in_group("encounter")
	if not (deck_hand or encounter):
		print("couldn't find deck hand or encounter")
	
	sprite.texture = load(card_info.texture_path)
	add_child(sprite)


func cast(player: NodePlayer, enemy: NodeEnemy) -> void:
	card_info.cast(self, player, enemy)

func discard():
	var hand_index = deck_hand.hand.cards.find(card_info)
	deck_hand.discard.add_card_to_deck(card_info)
	deck_hand.hand.cards.remove_at(hand_index)
	self.call_deferred("queue_free")


func _process(delta: float) -> void:
	pass
func _on_cardbody_mouse_entered() -> void:
	pass # Replace with function body.



func _on_cardbody_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true: #if left mouse down
			print("trying to send event")
			EventBus.card_clicked.emit(self)
	
	
