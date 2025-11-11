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


var cards_global: Dictionary = {}

func _ready() -> void:
	
	_add_card("attack_basic", {
		"name": "Attack",
		"description": "Deals damage to one enemy.",
		"texture_path": "res://art/cards/test_card.png",
		"cost_mana": 2,
		"damage_melee": 25
	})
	

func _process(delta: float) -> void:
	pass
	
	
func _add_card(id: String, data: Dictionary) -> void:
	var c := CardData.new()
	c.id = id
	for k in data.keys():
		if c.has_property(k):
			c.set(k, data[k])
	cards_global[id] = c

func get_card(id: String) -> CardData:
	return cards_global.get(id) 
