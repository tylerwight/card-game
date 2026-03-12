extends Node2D
#Holds global player state, as it moves through levels, creates decks, etc.
#Essentially the global savestate
@onready var deck: CardDB.DeckPlayable = CardDB.DeckPlayable.new()

func set_deck_default() -> void:
	if deck == null:
		deck = CardDB.DeckPlayable.new()
	deck.clear_deck_full()
	for i in range(5):
		deck.add_card_to_deck(CardDB.cards_global.get("strike"))
		deck.add_card_to_deck(CardDB.cards_global.get("defend"))
	deck.add_card_to_deck(CardDB.cards_global.get("bash"))
	deck.add_card_to_deck(CardDB.cards_global.get("anger"))
	#deck.add_card_to_deck(CardDB.cards_global.get("defend"))
	deck.add_card_to_deck(CardDB.cards_global.get("bodyslam"))
		

func _ready() -> void:
	add_to_group("player_manager")
	set_deck_default()
	deck.print_deck()


func _process(delta: float) -> void:
	pass
