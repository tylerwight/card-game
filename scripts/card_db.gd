extends Node

class CardData:
	extends Resource
	@export var id: String = "default"
	@export var name: String = "default"
	@export var description: String = "The default card"
	@export var texture_path: String = "res://assets/test_card.png"
	@export var cost_mana: int = 1
	@export var damage_melee: int = 1 
	@export var heal_std: int = 0
	@export var block_std: int = 0
	@export var needs_target: bool = true
	@export var effect: CardEffects.CardEffect
	@export var end: CardEffects.CardEffect
	@export var vulnerable: int = 0

	
	
	func cast(card: NodeCard, player: NodePlayer, enemy: NodeEnemy) -> void:
		if effect:
			effect.cast(card, player, enemy)
		else:
			print("No effect set for card ", id)
			

var cards_global: Dictionary = {}





func _ready() -> void:
	
	_add_card("strike", {
		"name": "Strike",
		"description": "Deals 6 damage to one enemy.",
		"texture_path": "res://assets/cards/red_card_attack.png",
		"cost_mana": 1,
		"damage_melee": 6,
		"effect": CardEffects.EffectAttack.new()
	})
	_add_card("defend", {
		"name": "Defend",
		"description": "Applies 5 Block to player",
		"texture_path": "res://assets/cards/red_card_block.png",
		"cost_mana": 1,
		"block_std": 5,
		"needs_target": false,
		"effect": CardEffects.EffectDefend.new()
	})
	_add_card("bash", {
		"name": "Bash",
		"description": "Deal 8 damage. Apply 2 Vulnerable",
		"texture_path": "res://assets/cards/red_card_block.png",
		"cost_mana": 2,
		"damage_melee": 8,
		"vulnerable": 2,
		"effect": CardEffects.EffectBash.new()
	})
	_add_card("anger", {
		"name": "Anger",
		"description": "Deal 6 damage. Add a copy of this card into your discard pile.",
		"texture_path": "res://assets/cards/red_card_attack.png",
		"cost_mana": 0,
		"damage_melee": 6,
		"effect": CardEffects.EffectAnger.new()
	})
	_add_card("bodyslam", {
		"name": "Body Slam",
		"description": "Deal damage equal to your block",
		"texture_path": "res://assets/cards/red_card_attack.png",
		"cost_mana": 1,
		"damage_melee": 0,
		"effect": CardEffects.EffectBodySlam.new()
	})

func _process(delta: float) -> void:
	pass
	
	
func _add_card(id: String, data: Dictionary) -> void:
	var c := CardData.new()
	c.id = id

	# Build a fast lookup set of valid property names on CardData
	var valid := {}
	for p in c.get_property_list():
		# Each entry p is a Dictionary; 'name' key gives the property name
		valid[p["name"]] = true

	# Apply only properties that actually exist on CardData
	for k in data.keys():
		if valid.has(k):
			c.set(k, data[k])
		else:
			push_warning("Unknown property on CardData: '%s'" % k)

	cards_global[id] = c

func get_card(id: String) -> CardData:
	var found = cards_global.get(id).duplicate()
	if found == null:
		print("ERROR: Couldn't find card: ", id)
		
	return found



class DeckPlayable:
	extends Resource
	@export var cards: Array[CardData]
	@export var name: String = "Default Deck"
	@export var texture_path: String = "res://assets/test_card.png"


	func add_card_to_deck(card: CardData) -> void:
		cards.push_back(card)
		
	func pull_card_from_deck() -> CardData:
		return cards.pop_front()
		
	func clear_deck_full() -> void:
		cards.clear()
		name = "Default Deck"
		texture_path = "res://assets/test_card.png"
		
		
	func print_deck(verbose: bool = false) -> void:
		if cards.is_empty():
			print("Deck '%s' has no cards." % name)
			return

		print("Cards in deck '%s':" % name)
		for card in cards:
			if card == null:
				print("  [NULL CARD]")
			elif verbose == false:
				print("  - %s (%s)" % [card.name, card.id])
			elif verbose == true:
				print("  - %s (%s)" % [card.name, card.id])
				print("      Cost: %d" % card.cost_mana)
				print("      Damage: %d" % card.damage_melee)
				print("      Heal: %d" % card.heal_std)
				print("      Block: %d" % card.block_std)
				print("")
