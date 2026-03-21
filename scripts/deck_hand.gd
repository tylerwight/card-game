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
	

func draw_hand(amount: int = draw_size):
	print("drawing: ", amount)
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
	var old_hand = get_children()
	for card in old_hand:
		card.queue_free()
		
	for card in hand.cards:
		var card_node = card_scene.instantiate()
		card_node.setup_card(card)
		add_child(card_node)
	refresh_layout()

func discard_hand():
	for card in hand.cards:
		discard.add_card_to_deck(card)
	hand.cards.clear()
	var rendered_cards = get_children()
	for card in rendered_cards:
		card.call_deferred("queue_free")
		


func _ready() -> void:
	var active_encounter = get_parent()
	deck = deck_reference.duplicate()
	hand.name = "HAND"
	discard.name = "DISCARD"
	deck.cards.shuffle()
	draw_hand()
	render_hand()


var frame_counter := 0
func _process(delta: float) -> void:
	frame_counter += 1
	if frame_counter % 3 == 0:
		pass


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
	discard.print_deck()
	print("=====")
	hand.print_deck()
	print("====")
	deck.print_deck()
