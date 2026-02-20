extends Node2D
class_name NodeEncounter
# Enemy clickable - done
# add card selection and playing
# add selecting enemies
#add text rendernig of things like HP, mana, etc.

const HAND_Y_FROM_BOTTOM := 120.0
const HAND_SPACING := 140.0
const ENEMY_Y_FRAC := 0.50  # 20% from top

enum phase {
	DRAW,
	UPKEEP,
	MAIN,
	RTS,
	CLEANUP
}

enum turn {
	PLAYER_1,
	ENEMIES
}

var encounter_phase := phase.MAIN
var encounter_turn := turn.PLAYER_1
var selected_card: NodeCard = null

var title: String = "big title!"

#var enemies: EnemyDb.EnemyData = EnemyDb.get_enemy("badboy")
var enemies_data: Array[EnemyDB.EnemyData]
var player_deck: CardDB.DeckPlayable
@onready var world_root: Node2D = $World
@onready var ui_layer: Control = $UI

var deck_hand: Node2D
var enemies: Array[Node2D]
var player: Node2D

func setup_encounter(deck: CardDB.DeckPlayable, enemies: Array[EnemyDB.EnemyData]):
	pass

func _ready() -> void:
	add_to_group("encounter")
	connect_signals()
	#attach_player()
	attach_enemies()
	attach_deck_hand()
	
	_layout()
	
	
	
	
func _process(delta: float) -> void:
	pass
	
	
func start_encounter() -> void:
	print("starting encounter")
	
func _layout() -> void:
	var screen := get_viewport().get_visible_rect().size
	
	var enemy_spacing = 100.0
	var start_x = screen.x * 0.75 - (enemy_spacing * (enemies.size() - 1) / 2.0)
	
	for i in range(enemies.size()):
		enemies[i].global_position = Vector2(start_x + i * enemy_spacing, screen.y * ENEMY_Y_FRAC)
		
	player.global_position = Vector2(300, screen.y * ENEMY_Y_FRAC)
	deck_hand.position = Vector2(screen.x * 0.5, screen.y - HAND_Y_FROM_BOTTOM)





func attach_deck_hand()-> void:
	var scene_deck_hand = preload("res://scenes/deck_hand.tscn")
	deck_hand = scene_deck_hand.instantiate()
	
	deck_hand.deck_reference = player_deck
	
	world_root.add_child(deck_hand)
	
	
#func attach_player()-> void:
	#var scene_player = preload("res://scenes/player.tscn")
	#player = scene_player.instantiate()
	#world_root.add_child(player)
	

func attach_enemies()-> void:
	var scene_enemy = preload("res://scenes/enemy.tscn")
	
	var enemy: Node2D
	for enemy_data in enemies_data:
		enemy = scene_enemy.instantiate()
		enemy.setup_enemy(enemy_data)
		world_root.add_child(enemy)
		enemies.push_back(enemy)

func _on_card_clicked(card: NodeCard) -> void:
	print("Encounter detected clicked card:", card.card_info.name)
	if (selected_card == card):
		selected_card = null
		print("Selected card: ", selected_card)
		return
	selected_card = card
	print("Selected card: ", selected_card.name)
	

func _on_enemy_clicked(enemy: NodeEnemy):
	print("Enemey has been clicked!")
	print(enemy.stats.name)
	if (selected_card == null):
		return
	EventBus.card_played.emit(player, selected_card, enemy)
	
func _on_card_played(player: NodePlayer, card: NodeCard, enemy: NodeEnemy):
	print("The card: " , card.name , " has been played by: ", player.player_name," on enemy: ", enemy.name)
	card.cast(player, enemy)
	selected_card = null
	

func connect_signals()-> void:
	EventBus.card_clicked.connect(_on_card_clicked)
	EventBus.enemy_clicked.connect(_on_enemy_clicked)
	EventBus.card_played.connect(_on_card_played)
	get_viewport().size_changed.connect(_layout)


func _on_playable_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true: #if left mouse down
			if not selected_card == null && selected_card.card_info.needs_target == false:
				selected_card.cast(player, null)


func _on_end_turn_pressed() -> void:
	deck_hand.discard_hand()
	deck_hand.draw_hand()
	deck_hand.print_status()
	deck_hand.render_hand()
	pass # Replace with function body.
