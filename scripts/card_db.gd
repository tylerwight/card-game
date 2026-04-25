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
	@export var ethereal = false

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
		
	func get_node(encounter: NodeEncounter) -> NodeCard:
		return encounter.deck_hand.get_card_nodes().filter(func(c): return is_same(c.card_info, self)).front()	
	
	func get_description() -> String:
		var tmp_text = description
		tmp_text = tmp_text.replace("~dmg~", str(damage_melee))		
		tmp_text = tmp_text.replace("~blk~", str(block_std))
		tmp_text = tmp_text.replace("~vul~", str(vulnerable))	
		tmp_text = tmp_text.replace("~weak~", str(weak))	
		tmp_text = tmp_text.replace("~str~", str(strength))	
		return tmp_text
		
	func get_dynamic_desc(damage: int) -> String:
		var tmp_text = dynamic_desc
		tmp_text = tmp_text.replace("~dmg~", str(damage))
		tmp_text = tmp_text.replace("~blk~", str(block_std))
		tmp_text = tmp_text.replace("~vul~", str(vulnerable))	
		tmp_text = tmp_text.replace("~weak~", str(weak))	
		tmp_text = tmp_text.replace("~str~", str(strength))	
		return tmp_text
		
	func get_cost(card: NodeCard, player: NodePlayer) -> int:
		return effect.get_cost(card, player)
		
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
		"description": "Can only be played if every card in your hand is an Attack. Deal ~dmg~ damage.",
		"dynamic_desc": "Can only be played if every card in your hand is an Attack. Deal [color=green]~dmg~[/color] damage.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 0,
		"damage_melee": 14,
		"effect": CardEffects.EffectClash.new()
	})
	_add_card("inflame", {
		"name": "Inflame",
		"type": "power",
		"description": "Gain 2 Strength",
		"dynamic_desc": "Gain 2 Strength",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"strength": 2,
		"needs_target": false,
		"effect": CardEffects.EffectInflame.new()
	})
	_add_card("cleave", {
		"name": "Cleave",
		"type": "attack",
		"description": "Deal ~dmg~ damage to ALL enemies",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage to ALL enemies",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"needs_target": false,
		"effect": CardEffects.EffectCleave.new()
	})
	_add_card("flex", {
		"name": "Flex",
		"type": "skill",
		"description": "Add ~str~ strength. At the end of yoru turn remove ~str~ strength.",
		"dynamic_desc": "Add ~str~ strength. At the end of yoru turn remove ~str~ strength.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 0,
		"strength": 2,
		"needs_target": false,
		"effect": CardEffects.EffectFlex.new()
	})
	_add_card("havoc", {
		"name": "Havoc",
		"type": "skill",
		"description": "Play the top card of your draw pile and Exhaust it.",
		"dynamic_desc": "Play the top card of your draw pile and Exhaust it.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"needs_target": false,
		"effect": CardEffects.EffectHavoc.new()
	})
	_add_card("headbutt", {
		"name": "Headbutt",
		"type": "attack",
		"description": "Deal ~dmg~ damage. Place a card from your discard pile on top of your draw pile.",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage. Place a card from your discard pile on top of your draw pile.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"damage_melee": 9,
		"effect": CardEffects.EffectHeadbutt.new()
	})
	_add_card("heavyblade", {#revisit
		"name": "Heavy Blade",
		"type": "attack",
		"description": "Deal ~dmg~ damage. Strength affects Heavy Blade 3 times.",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage. Strength affects Heavy Blade 3 times.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 2,
		"damage_melee": 14,
		"effect": CardEffects.EffectHeavyblade.new()
	})
	_add_card("armaments", {#revisit
		"name": "Armaments",
		"type": "skill",
		"description": "Gain ~blk~ block. Upgrade a card in your hand for the rest of combat.",
		"dynamic_desc": "Gain ~blk~ block. Upgrade a card in your hand for the rest of combat.",
		"texture_path": "res://assets/cards/green_card_attack_defend.png",
		"cost_mana": 1,
		"block_std": 5,
		"needs_target": false,
		"effect": CardEffects.EffectArmaments.new()
	})
	_add_card("ironwave", {
		"name": "Iron Wave",
		"type": "attack",
		"description": "Gain ~blk~ Block. Deal ~dmg~ damage.",
		"dynamic_desc": "Gain ~blk~ Block. Deal [color=green]~dmg~[/color] damage.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"damage_melee": 5,
		"block_std": 5,
		"effect": CardEffects.EffectIronwave.new()
	})
	_add_card("perfectedstrike", {#revisit
		"name": "Perfected Strike",
		"type": "attack",
		"description": "Deal ~dmg~ damage. Deals an additional 2 damage for ALL of your cards containing 'Strike'.",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage. Deals an additional 2 damage for ALL of your cards containing 'Strike'.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 2,
		"damage_melee": 6,
		"effect": CardEffects.EffectPerfectedstrike.new()
	})
	_add_card("pommelstrike", {#revisit
		"name": "Pommel Strike",
		"type": "attack",
		"description": "Deal ~dmg~ damage. Draw 1 card.",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage. Draw 1 card.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"damage_melee": 9,
		"effect": CardEffects.EffectPommelstrike.new()
	})
	_add_card("shrugitoff", {#revisit
		"name": "Shrug It Off",
		"type": "skill",
		"description": "Gain ~blk~ block. Draw 1 card.",
		"dynamic_desc": "Gain ~blk~ block. Draw 1 card.",
		"texture_path": "res://assets/cards/green_card_attack_defend.png",
		"cost_mana": 1,
		"block_std": 8,
		"needs_target": false,
		"effect": CardEffects.EffectShrugitoff.new()
	})
	_add_card("swordboomerang", {#revisit
		"name": "Sword Boomerang",
		"type": "attack",
		"description": "Deal ~dmg~ damage to a random enemy 3 times.",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage to a random enemy 3 times.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"damage_melee": 3,
		"effect": CardEffects.EffectSwordboomerang.new()
	})
	_add_card("thunderclap", {#revisit
		"name": "Thunderclap",
		"type": "attack",
		"description": "Deal ~dmg~ damage and apply 1 Vulnerable to ALL enemies.",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage and apply 1 Vulnerable to ALL enemies.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"damage_melee": 4,
		"vulnerable": 1,
		"needs_target": false,
		"effect": CardEffects.EffectThunderclap.new()
	})
	_add_card("truegrit", {#revisit
		"name": "True Grit",
		"type": "skill",
		"description": "Gain ~blk~ Block. Exhaust a random card from your hand.",
		"dynamic_desc": "Gain ~blk~ Block. Exhaust a random card from your hand.",
		"texture_path": "res://assets/cards/green_card_attack_defend.png",
		"cost_mana": 1,
		"block_std": 7,
		"needs_target": false,
		"effect": CardEffects.EffectTruegrit.new()
	})
	_add_card("twinstrike", {#revisit
		"name": "Twin Strike",
		"type": "attack",
		"description": "Deal ~dmg~ damage twice.",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage twice.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"damage_melee": 5,
		"effect": CardEffects.EffectTwinstrike.new()
	})
	_add_card("warcry", {#revisit
		"name": "Warcry",
		"type": "skill",
		"description": "Draw 1 card. Place a card from your hand on top of your draw pile. Exhaust.",
		"dynamic_desc": "Draw 1 card. Place a card from your hand on top of your draw pile. Exhaust.",
		"texture_path": "res://assets/cards/green_card_attack_defend.png",
		"cost_mana": 0,
		"needs_target": false,
		"effect": CardEffects.EffectWarcry.new()
	})
	_add_card("wound", {#revisit
		"name": "Wound",
		"type": "status",
		"description": "Unplayable",
		"dynamic_desc": "Unplayable",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 0,
		"effect": CardEffects.EffectWound.new()
	})	
	_add_card("wildstrike", {#revisit
		"name": "Wild Strike",
		"type": "attack",
		"description": "Deal ~dmg~ damage. Shuffle a Wound into your draw pile.",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage. Shuffle a Wound into your draw pile.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"damage_melee": 12,
		"effect": CardEffects.EffectWildstrike.new()
	})	
	_add_card("battletrance", {#revisit
		"name": "Battle Trance",
		"type": "skill",
		"description": "Draw 3 cards. You cannot draw additional cards this turn.",
		"dynamic_desc": "Draw 3 cards. You cannot draw additional cards this turn.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 0,
		"needs_target": false,
		"effect": CardEffects.EffectBattletrance.new()
	})		
	_add_card("bloodforblood", {#revisit
		"name": "Blood for Blood",
		"type": "attack",
		"description": "Costs 1 less energy for each time you lose HP in combat. Deal ~dmg~ damage.",
		"dynamic_desc": "Costs 1 less energy for each time you lose HP in combat. Deal [color=green]~dmg~[/color] damage.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 4,
		"damage_melee": 18,
		"effect": CardEffects.EffectBloodForBlood.new()
	})	
	_add_card("blootletting", {#revisit
		"name": "Bloodletting",
		"type": "skill",
		"description": "Lose 3 HP. Gain 2 Energy.",
		"dynamic_desc": "Lose 3 HP. Gain 2 Energy.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 0,
		"needs_target": false,
		"effect": CardEffects.EffectBloodletting.new()
	})	
	_add_card("burningpact", {#revisit
		"name": "Burning Pact",
		"type": "skill",
		"description": "Exhaust 1 card. Draw 2 cards.",
		"dynamic_desc": "Exhaust 1 card. Draw 2 cards.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"needs_target": false,
		"effect": CardEffects.EffectBurningpact.new()
	})	
	_add_card("carnage", {#revisit
		"name": "Carnage",
		"type": "attack",
		"description": "Ethereal. Deal ~dmg~ damage.",
		"dynamic_desc": "Ethereal. Deal [color=green]~dmg~[/color] damage.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 2,
		"damage_melee": 18,
		"ethereal": true,
		"effect": CardEffects.EffectCarnage.new()
	})		
	_add_card("combust", {#revisit
		"name": "Combust",
		"type": "power",
		"description": "At the end of your turn, lose 1 HP and deal 5 damage to ALL enemies.",
		"dynamic_desc": "At the end of your turn, lose 1 HP and deal 5 damage to ALL enemies.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"needs_target": false,
		"effect": CardEffects.EffectCombust.new()
	})		
	_add_card("darkembrace", {#revisit
		"name": "Dark Embrace",
		"type": "power",
		"description": "Whenever a card is Exhausted, draw 1 card.",
		"dynamic_desc": "Whenever a card is Exhausted, draw 1 card.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 2,
		"needs_target": false,
		"effect": CardEffects.EffectDarkembrace.new()
	})		
	_add_card("disarm", {#revisit
		"name": "Disarm",
		"type": "skill",
		"description": "Enemy loses 2 strength. Exhaust.",
		"dynamic_desc": "Enemy loses 2 strength. Exhaust.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 1,
		"strength": -2,
		"effect": CardEffects.EffectDisarm.new()
	})		
	_add_card("dropkick", {#revisit
		"name": "Dropkick",
		"type": "attack",
		"description": "Deal ~dmg~ damage. If the enemy is Vulnerable, gain 1 energy and draw 1 card.",
		"dynamic_desc": "Deal [color=green]~dmg~[/color] damage. If the enemy is Vulnerable, gain 1 energy and draw 1 card.",
		"texture_path": "res://assets/cards/green_card_attack_strike.png",
		"cost_mana": 2,
		"damage_melee": 18,
		"effect": CardEffects.EffectCarnage.new()
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



	func add_card_to_deck_random(card: CardData) -> void:
		cards.insert(randi_range(0, cards.size()), card)
	
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
	
	func remove_card(card: CardData) -> bool:
		var index = cards.find(card)
		if index != -1:
			cards.remove_at(index)
			return true
		return false
	
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
