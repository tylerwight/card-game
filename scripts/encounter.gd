extends Node2D

const HAND_Y_FROM_BOTTOM := 120.0
const HAND_SPACING := 140.0
const ENEMY_Y_FRAC := 0.20  # 20% from top

var title: String = "big title!"
#var enemies: EnemyDb.EnemyData = EnemyDb.get_enemy("badboy")
var enemies_data: Array[EnemyDb.EnemyData]

@onready var world_root: Node2D = $World
@onready var ui_layer: CanvasLayer = $UI

var deck_hand: Node2D
var enemies: Array[Node2D]

func _ready() -> void:
	EventBus.card_played.connect(_on_card_played)
	var scene_deck_hand = preload("res://scenes/deck_hand.tscn")
	deck_hand = scene_deck_hand.instantiate()
	ui_layer.add_child(deck_hand)
	
	var scene_enemy = preload("res://scenes/enemy.tscn")
	
	var enemy: Node2D
	for enemy_data in enemies_data:
		enemy = scene_enemy.instantiate()
		enemy.setup_enemy(enemy_data)
		world_root.add_child(enemy)
		enemies.push_back(enemy)
	
	

	_layout()
	
	get_viewport().size_changed.connect(_layout)
		
	
func _layout() -> void:
	var screen := get_viewport().get_visible_rect().size
	
	var spacing = 200.0
	var start_x = screen.x * 0.5 - (spacing * (enemies.size() - 1) / 2.0)
	
	for i in range(enemies.size()):
		enemies[i].global_position = Vector2(start_x + i * spacing, screen.y * ENEMY_Y_FRAC)
	deck_hand.position = Vector2(screen.x * 0.5, screen.y - HAND_Y_FROM_BOTTOM)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_card_played(card_info: CardDb.CardData) -> void:
	print("Encounter detected card played:", card_info.name)
