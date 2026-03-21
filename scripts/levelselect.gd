extends Control

var test: int = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_1_pressed() -> void:
	var player_manager := get_tree().get_first_node_in_group("player_manager")
	
	var enemies: Array[EnemyDB.EnemyData]
	enemies.push_back(EnemyDB.get_enemy("orc"))
	enemies.push_back(EnemyDB.get_enemy("skeleton"))
	Main.hide_ui()
	Main.create_encounter(player_manager, enemies, "Level 1")


func _on_choose_deck_pressed() -> void:
	var cards_global_array: Array[CardDB.CardData]
	for key in CardDB.cards_global:
		cards_global_array.append(CardDB.cards_global[key])
		
		
	var player_manager := get_tree().get_first_node_in_group("player_manager")
	var picked_cards = await Main.create_card_picker(cards_global_array, "Pick 1 card to add to deck", 1, false)
	for card in picked_cards:
		print(card.name)
		player_manager.deck.add_card_to_deck(card)


	
