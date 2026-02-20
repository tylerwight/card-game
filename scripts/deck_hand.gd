extends Node2D
class_name NodeDeckHand
var active_encounter: Node2D
var deck_reference: CardDB.DeckPlayable

@onready var deck: CardDB.DeckPlayable = CardDB.DeckPlayable.new()
@onready var discard: CardDB.DeckPlayable = CardDB.DeckPlayable.new()
@onready var hand: CardDB.DeckPlayable = CardDB.DeckPlayable.new()
@onready var exhausted: CardDB.DeckPlayable = CardDB.DeckPlayable.new()

@onready var hand_size_max = 10
@onready var draw_size = 4
@onready var card_scene = preload("res://scenes/card.tscn")

func shuffle_discard():
	for card in discard.cards:
		deck.add_card_to_deck(card)
	discard.cards.clear()
	deck.cards.shuffle()
	

func draw_hand(amount: int = draw_size):
	print("drawing: ", amount)
	
	for i in range(amount):
		print("on I: ", i, " deck size: ", deck.cards.size())
		if deck.cards.size() > 0 and hand.cards.size() < hand_size_max:
			#hand.cards.push_back(deck.cards.pop_front())
			hand.add_card_to_deck(deck.pull_card_from_deck())
		if deck.cards.size() == 0:
			print("shuffle drawing: ", amount - i)
			shuffle_discard()
			i = i - 1

func render_hand():
	var old_hand = get_children()
	for card in old_hand:
		card.call_deferred("queue_free")
		
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
	draw_hand()
	render_hand()


var frame_counter := 0
func _process(delta: float) -> void:
	frame_counter += 1
	if frame_counter % 3 == 0:
		refresh_layout()


func refresh_layout() -> void:
	var cards := get_children()
	var count := cards.size()
	if count == 0:
		return

	var spacing := 120.0                     # horizontal distance between cards
	var total_width := spacing * (count - 1)

	var hand_y := 0                          # cards sit at deck_hand.position.y
	var start_x := -total_width * 0.5        # makes the hand centered

	for i in range(count):
		var card := cards[i]
		card.position = Vector2(start_x + i * spacing, hand_y)
		
		
func print_status() -> void:
	discard.print_deck()
	print("=====")
	hand.print_deck()
	print("====")
	deck.print_deck()
