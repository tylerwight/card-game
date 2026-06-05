extends Node

class IconData:
	extends Resource
	@export var id: String = "default"
	@export var name: String = "Default Blob"
	@export var description: String = "He's so default"
	@export var texture: String = "res://assets/icons/star1.png"

		
			
			


var icons_global: Dictionary = {}

func _ready() -> void:
	_add_icon("strength", {
		"name": "Strength",
		"description": "Each Strength adds 1 to owners attacks",
		"texture": "res://assets/icons/str1.png",
	})
	_add_icon("weak", {
		"name": "Weak",
		"description": "Reduces owner attack by 25%",
		"texture": "res://assets/icons/weak1.png",
	})
	_add_icon("vulnerable", {
		"name": "Vulnerable",
		"description": "Owner takes 50% more damage",
		"texture": "res://assets/icons/vuln1.png",
	})
	_add_icon("flex", {
		"name": "Flex",
		"description": "Strength is lost at end of turn",
		"texture": "res://assets/icons/flex1.png",
	})
	_add_icon("battle_trance", {
		"name": "Battle Trance",
		"description": "Cannot draw additional cards this turn",
		"texture": "res://assets/icons/battle_trance1.png",
	})
	_add_icon("combust", {
		"name": "Combust",
		"description": "At end of turn, lose 1 HP and deal 5 damage to all enemies",
		"texture": "res://assets/icons/combust1.png",
	})
	_add_icon("dark_embrace", {
		"name": "Dark Embrace",
		"description": "Whenever a card is exhausted, draw 1 card",
		"texture": "res://assets/icons/dark_embrace1.png",
	})
	_add_icon("evolve", {
		"name": "Evolve",
		"description": "Whenever a status card is drawn, draw additional cards",
		"texture": "res://assets/icons/evolve.png",
	})
	_add_icon("fire_breathing", {
		"name": "Fire Breathing",
		"description": "Whenever a status or curse is drawn, deal damage to all enemies",
		"texture": "res://assets/icons/star1.png",
	})
	_add_icon("flame_barrier", {
		"name": "Flame Barrier",
		"description": "Whenever attacked, deal damage back to attacker",
		"texture": "res://assets/icons/fire_breathing.png",
	})
	_add_icon("metallicize", {
		"name": "Metallicize",
		"description": "At end of turn, gain Block",
		"texture": "res://assets/icons/metallicize1.png",
	})
	_add_icon("rage", {
		"name": "Rage",
		"description": "Whenever an attack card is played, gain Block",
		"texture": "res://assets/icons/rage1.png",
	})
	_add_icon("juggernaut", {
		"name": "Juggernaut",
		"description": "Whenever Block is gained, deal damage to a random enemy",
		"texture": "res://assets/icons/juggernaut.png",
	})
	_add_icon("feel_no_pain", {
		"name": "Feel No Pain",
		"description": "Whenever a card is exhausted, gain Block",
		"texture": "res://assets/icons/feel_no_pain.png",
	})
	_add_icon("rupture", {
		"name": "Rupture",
		"description": "Whenever HP is lost from a card, gain Strength",
		"texture": "res://assets/icons/rupture1.png",
	})
	_add_icon("barricade", {
		"name": "Barricade",
		"description": "Block is no longer removed at end of turn",
		"texture": "res://assets/icons/barricade1.png",
	})
	_add_icon("berserk", {
		"name": "Berserk",
		"description": "At the start of turn, gain 1 Energy",
		"texture": "res://assets/icons/berserk1.png",
	})
	_add_icon("brutality", {
		"name": "Brutality",
		"description": "At start of turn, lose 1 HP and draw 1 card",
		"texture": "res://assets/icons/brutality1.png",
	})
	_add_icon("corruption", {
		"name": "Corruption",
		"description": "Skill cards cost 0 and are exhausted when played",
		"texture": "res://assets/icons/corruption1.png",
	})
	_add_icon("demon_form", {
		"name": "Demon Form",
		"description": "At end of enemy turn, gain Strength",
		"texture": "res://assets/icons/demon_form1.png",
	})
	_add_icon("double_tap", {
		"name": "Double Tap",
		"description": "The next attack card played this turn is played twice",
		"texture": "res://assets/icons/double_tap1.png",
	})
	

func _process(delta: float) -> void:
	pass
	

func _add_icon(id: String, data: Dictionary) -> void:
	var icon := IconData.new()
	icon.id = id

	# Build a fast lookup set of valid property names on CardData
	var valid := {}
	for p in icon.get_property_list():
		# Each entry p is a Dictionary; 'name' key gives the property name
		valid[p["name"]] = true

	# Apply only properties that actually exist on CardData
	for k in data.keys():
		if valid.has(k):
			icon.set(k, data[k])
		else:
			push_warning("Unknown property on CardData: '%s'" % k)

	icons_global[id] = icon


func get_icon(id: String) -> IconData:
	return icons_global.get(id).duplicate()

var icon_scene = preload("res://scenes/icon.tscn")

func create_icon_node(id: String) -> Node:
	var data = icons_global.get(id)
	if not data:
		push_warning("IconDB: unknown icon id '%s'" % id)
		return null
	var icon = icon_scene.instantiate()
	icon.setup(data)
	return icon
