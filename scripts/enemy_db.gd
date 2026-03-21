extends Node

class EnemyData:
	extends Resource
	@export var id: String = "default"
	@export var name: String = "Default Blob"
	@export var description: String = "He's so default"
	@export var texture_path: String = "res://assets/bringer-of-death.png"
	@export var health: int = 100
	@export var block: int = 0 
	@export var heal_std: int = 0
	@export var block_std: int = 0
	@export var vulnerable: int = 0
	@export var weak: int = 0
	@export var behavior: EnemyBehaviors.EnemyBehavior
	
	func roll_intents() -> void:
		if behavior:
			behavior.roll_intents(self)
	
	func take_turn(player: NodePlayer, enemy: NodeEnemy) -> void:
		if behavior:
			behavior.take_turn(player, enemy)
		else:
			print("No behavior set for enemy", name)

var enemies_global: Dictionary = {}

func _ready() -> void:
	
	_add_enemy("badboy", {
		"name": "Bad Boy",
		"description": "Oooo he bad",
		"texture_path": "res://assets/badboy/",
		"health": 32,
		"behavior": EnemyBehaviors.BehaviorBadboy.new()
	})
	
	_add_enemy("goodboy", {
		"name": "Good Boy",
		"description": "Oooo he Good",
		"texture_path": "res://assets/goodboy/",
		"health": 35,
		"behavior": EnemyBehaviors.BehaviorGoodboy.new()
	})
	
	_add_enemy("orc", {
		"name": "Orc",
		"description": "Zug Zug",
		"texture_path": "res://assets/orc/",
		"health": 35,
		"behavior": EnemyBehaviors.BehaviorGoodboy.new()
	})
	
	_add_enemy("skeleton", {
		"name": "Skeleton",
		"description": " *bone rattles* ",
		"texture_path": "res://assets/skeleton/",
		"health": 35,
		"behavior": EnemyBehaviors.BehaviorGoodboy.new()
	})
	

func _process(delta: float) -> void:
	pass
	

func _add_enemy(id: String, data: Dictionary) -> void:
	var enemy := EnemyData.new()
	enemy.id = id

	# Build a fast lookup set of valid property names on CardData
	var valid := {}
	for p in enemy.get_property_list():
		# Each entry p is a Dictionary; 'name' key gives the property name
		valid[p["name"]] = true

	# Apply only properties that actually exist on CardData
	for k in data.keys():
		if valid.has(k):
			enemy.set(k, data[k])
		else:
			push_warning("Unknown property on CardData: '%s'" % k)

	enemies_global[id] = enemy


func get_enemy(id: String) -> EnemyData:
	return enemies_global.get(id).duplicate()
