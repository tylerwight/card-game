extends Node

class CardData:
	extends Resource
	@export var id: String = "default"
	@export var name: String = "default"
	@export var type: String = "default123"
	@export var description: String = "The default card"
	@export var dynamic_desc: String = "the default"
	@export var texture_path: String = "res://assets/test_card.png"
	@export var cost_mana: int = 1
	@export var damage_melee: int = 1 
	@export var damage_actual: int = 0
	@export var heal_std: int = 0
	@export var block_std: int = 0
	@export var needs_target: bool = true
	@export var effect: CardEffects.CardEffect
	@export var end: CardEffects.CardEffect
	@export var vulnerable: int = 0
	@export var weak: int = 0
	@export var strength: int = 0
	@export var discard_to_exhuast: bool = false
	@export var upgraded = false

	func populate_damage_actual(encounter: NodeEncounter, card: NodeCard):
		damage_actual = damage_melee
		
		var effects = encounter.player.player_effects
		for effect in effects:
			effect.process_attacking_player(encounter, card)
			
		#print("card actual damage is: ", damage_actual, "   coming from damage_melee: ", damage_melee)

	func card_playable(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> Dictionary:
		return effect.card_playable(card, player, enemy)
	
	func cast(card: NodeCard, player: NodePlayer, enemy: NodeEnemy) -> void:
		print("====CASTING CARD==== ", card.card_info.name)
		if effect:
			effect.cast(card, player, enemy)
		else:
			print("No effect set for card ", id)
			
			
	func upgrade() -> void:
		effect.upgrade(self)	
		
	func get_description() -> String:
		var tmp_text = description
		tmp_text = tmp_text.replace("~dmg~", str(damage_melee))		
		tmp_text = tmp_text.replace("~blk~", str(block_std))
		tmp_text = tmp_text.replace("~vul~", str(vulnerable))	
		tmp_text = tmp_text.replace("~weak~", str(weak))	
		return tmp_text
		
	func get_dynamic_desc(damage: int) -> String:
		var tmp_text = dynamic_desc
		tmp_text = tmp_text.replace("~dmg~", str(damage))
		tmp_text = tmp_text.replace("~blk~", str(block_std))
		tmp_text = tmp_text.replace("~vul~", str(vulnerable))	
		tmp_text = tmp_text.replace("~weak~", str(weak))	
		return tmp_text
		
		
	func print_self() -> void:
		print("=== CardData: ", name, " ===")
		for property in get_property_list():
			# Filter to only @export vars (usage flag 4096 = PROPERTY_USAGE_SCRIPT_VARIABLE)
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				print(property.name, ": ", get(property.name))
			

var cards_global: Dictionary = {}





func _ready() -> void:
	
	_add_card("strike", {
		"name": "Strike",
		"type": "attack",
		"description": "Deals ~dmg~ damage to one enemy.",
		"dynamic_desc": "Deals [color=green]~dmg~[/color] damage to one enemy.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"damage_melee": 6,
		"effect": CardEffects.EffectAttack.new()
	})
	_add_card("defend", {
		"name": "Defend",
		"type": "skill",
		"description": "Applies ~blk~ block to player",
		"dynamic_desc": "Applies [color=green]~blk~[/color] block to player",
		"texture_path": "res://assets/cards/green_card_attack_defend.png",
		"cost_mana": 1,
		"block_std": 5,
		"needs_target": false,
		"effect": CardEffects.EffectDefend.new()
	})
	_add_card("bash", {
		"name": "Bash",
		"type": "attack",
		"description": "Deal ~dmg~ damage. Apply ~vul~ Vulnerable",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage. Apply ~vul~ Vulnerable",
		"texture_path": "res://assets/cards/green_card_attack_bash.png",
		"cost_mana": 2,
		"damage_melee": 8,
		"vulnerable": 2,
		"effect": CardEffects.EffectBash.new()
	})
	_add_card("anger", {
		"name": "Anger",
		"type": "attack",
		"description": "Deal ~dmg~ damage. Add a copy of this card into your discard pile.",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage. Add a copy of this card into your discard pile.",
		"texture_path": "res://assets/cards/green_card_attack_anger.png",
		"cost_mana": 0,
		"damage_melee": 6,
		"effect": CardEffects.EffectAnger.new()
	})
	_add_card("bodyslam", {
		"name": "Body Slam",
		"type": "attack",
		"description": "Deal damage equal to your block",
		"dynamic_desc": "Deal damage equal to your block",
		"texture_path": "res://assets/cards/green_card_attack_bodyslam.png",
		"cost_mana": 1,
		"damage_melee": 0,
		"effect": CardEffects.EffectBodySlam.new()
	})
	_add_card("clothesline", {
		"name": "Clothesline",
		"type": "attack",
		"description": "Deal ~dmg~ damage. Apply ~weak~ Weak",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage. Apply ~weak~ Weak",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 2,
		"damage_melee": 12,
		"weak": 2,
		"effect": CardEffects.EffectClothesline.new()
	})
	_add_card("clash", {
		"name": "Clash",
		"type": "attack",
		"description": "Can only be played if every card in your hand is an Attack. Deal 14 damage.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 0,
		"damage_melee": 14,
		"effect": CardEffects.EffectClash.new()
	})
	_add_card("inflame", {
		"name": "Inflame",
		"type": "power",
		"description": "Gain 2 Strength",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"strength": 2,
		"needs_target": false,
		"effect": CardEffects.EffectInflame.new()
	})
	_add_card("cleave", {
		"name": "Cleave",
		"type": "attack",
		"description": "Deal 8 damage to ALL enemies",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"needs_target": false,
		"effect": CardEffects.EffectCleave.new()
	})
	_add_card("flex", {
		"name": "Flex",
		"type": "skill",
		"description": "Add 2 strength. At the end of yoru turn remove 2 strength.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 0,
		"strength": 2,
		"needs_target": false,
		"effect": CardEffects.EffectFlex.new()
	})
	_add_card("havoc", {
		"name": "Havoc",
		"type": "skill",
		"description": "	Play the top card of your draw pile and Exhaust it.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"needs_target": false,
		"effect": CardEffects.EffectHavoc.new()
	})
	_add_card("headbutt", {
		"name": "Headbutt",
		"type": "attack",
		"description": "	Deal 9 damage. Place a card from your discard pile on top of your draw pile.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"damage_melee": 9,
		"effect": CardEffects.EffectHeadbutt.new()
	})
	_add_card("heavyblade", {
		"name": "Heavy Blade",
		"type": "attack",
		"description": "	Deal 14 damage. Strength affects Heavy Blade 3 times.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 2,
		"damage_melee": 14,
		"effect": CardEffects.EffectHeavyblade.new()
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
		
	func add_card_to_deck_front(card: CardData) -> void:
		cards.push_front(card)
		
	func pull_card_from_deck() -> CardData:
		return cards.pop_front()
		
	func pull_random_from_deck() -> CardData:
		if cards.is_empty():
			return null
		return cards.pop_at(randi() % cards.size())
	
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
