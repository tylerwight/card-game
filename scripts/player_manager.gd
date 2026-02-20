extends Node2D
#Holds global player state, as it moves through levels, creates decks, etc.
#Essentially the global savestate
@onready var deck: CardDB.DeckPlayable = CardDB.DeckPlayable.new()

func set_deck_default() -> void:
	if deck == null:
		deck = CardDB.DeckPlayable.new()
	deck.clear_deck_full()
	for i in range(5):
		deck.add_card_to_deck(CardDB.cards_global.get("attack_basic"))
		deck.add_card_to_deck(CardDB.cards_global.get("defend_basic"))
		

func _ready() -> void:
	add_to_group("player_manager")
	set_deck_default()
	deck.print_deck()


func _process(delta: float) -> void:
	pass
