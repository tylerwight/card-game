extends Node2D
class_name NodeDeckHand
var active_encounter: Node2D
var deck_reference: CardDB.DeckPlayable

@onready var deck: CardDB.DeckPlayable = CardDB.DeckPlayable.new()
@onready var discard: CardDB.DeckPlayable = CardDB.DeckPlayable.new()
@onready var hand: CardDB.DeckPlayable = CardDB.DeckPlayable.new()
@onready var exhausted: CardDB.DeckPlayable = CardDB.DeckPlayable.new()

@onready var hand_size_max = 10
@onready var draw_size = 5
@onready var card_scene = preload("res://scenes/card.tscn")


func shuffle_discard():
	for card in discard.cards:
		deck.add_card_to_deck(card)
	discard.cards.clear()
	deck.cards.shuffle()
	

func draw_hand(inital_draw: bool, amount: int = draw_size):
	print("drawing: ", amount)
	
	if inital_draw == false:
		for effect in active_encounter.player.player_effects.duplicate():
			amount = effect.process_draw_player(active_encounter, amount)
			if effect.deleteme == true:
				active_encounter.player.player_effects.erase(effect)
			
			
	print("draw after draw effects:", amount)
	var total_cards = deck.cards.size() + hand.cards.size() + discard.cards.size()
	
	for i in range(amount):
		#print("on I: ", i, " deck size: ", deck.cards.size())
		if deck.cards.size() > 0 and hand.cards.size() < hand_size_max:
			hand.add_card_to_deck(deck.pull_card_from_deck())
		elif deck.cards.size() == 0 and total_cards > hand.cards.size():
			print("shuffle drawing: ", amount - i)
			shuffle_discard()
			hand.add_card_to_deck(deck.pull_card_from_deck())




func render_hand():
	var old_hand = get_card_nodes()
	for card in old_hand:
		card.queue_free()
		
	for card in hand.cards:
		var card_node = card_scene.instantiate()
		card_node.setup_card(card)
		add_child(card_node)
	refresh_layout()

func get_card_nodes() -> Array[NodeCard]:
	var card_nodes: Array[NodeCard] = []
	for child in get_children():
		if child is NodeCard:
			card_nodes.append(child)
	return card_nodes

func discard_hand():
	for card in hand.cards:
		if card.ethereal == true:
			exhausted.add_card_to_deck(card)
		else:
			discard.add_card_to_deck(card)
	hand.cards.clear()
	var rendered_cards = get_card_nodes()
	for card in rendered_cards:
		card.call_deferred("queue_free")
		


func _ready() -> void:
	active_encounter = Main.get_tree().get_first_node_in_group("encounter")
	deck = deck_reference.duplicate()
	hand.name = "HAND"
	discard.name = "DISCARD"
	exhausted.name = "EXHAUSTED"
	deck.name = "DECK"
	deck.cards.shuffle()
	draw_hand(true)
	render_hand()


var frame_counter := 0
func _process(delta: float) -> void:
	frame_counter += 1
	if frame_counter % 3 == 0:
		pass

func update_card_labels() -> void:
	var cards: Array[NodeCard] = []
	for child in get_children():
		if child is NodeCard and not child.is_queued_for_deletion():
			cards.append(child)
			child._update_labels()
	


func refresh_layout() -> void:
	var cards: Array[NodeCard] = []
	for child in get_children():
		if child is NodeCard and not child.is_queued_for_deletion():
			cards.append(child)
	var count := cards.size()
	if count == 0:
		return

	var spacing := 120.0
	var total_width := spacing * (count - 1)
	var start_x := -total_width * 0.5
	var arc_height := 18.0   # how much the edges dip down vs center
	var max_rotation := 6.0  # max tilt in degrees at the edges

	for i in range(count):
		var card := cards[i]
		# t goes from -1 (leftmost) to +1 (rightmost)
		var t := -1.0 if count == 1 else (float(i) / (count - 1)) * 2.0 - 1.0

		var x := start_x + i * spacing
		var y := t * t * arc_height  # parabola: center is highest, edges dip down
		card.position = Vector2(x, y)
		card.home_position = Vector2(x, y)
		card.rotation_degrees = t * max_rotation
		
		
func print_status() -> void:
	deck.print_deck()
	print("=====")
	hand.print_deck()
	print("=====")
	discard.print_deck()
	print("=====")
	exhausted.print_deck()
