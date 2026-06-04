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
	
	_add_icon("skeleton", {
		"name": "Skeleton",
		"description": " *bone rattles* ",
		"texture": "res://assets/icons/star1.png",

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
