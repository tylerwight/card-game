extends Node2D
class_name NodeEncounter
# Enemy clickable - done
# add card selection and playing
# add selecting enemies
#add text rendernig of things like HP, mana, etc.

const HAND_Y_FROM_BOTTOM := 120.0
const HAND_SPACING := 140.0
const ENEMY_Y_FRAC := 0.50  # 20% from top
const CARD_DRAG_BOX_HALF := Vector2(100.0, 80.0)  # (left/right, up)
const CARD_DRAG_SPEED := 10.0                      # higher = snappier
const CARD_DRAG_SOFTNESS := 0.75                   # 0..1, higher = more slowdown near edge
var selected_card_home_pos: Vector2 = Vector2.ZERO


#enum phase {
	#DRAW,
	#UPKEEP,
	#MAIN,
	#RTS,
	#CLEANUP
#}
#
#enum turn {
	#PLAYER_1,
	#ENEMIES
#}
#
#var encounter_phase := phase.MAIN
#var encounter_turn := turn.PLAYER_1
var selected_card: NodeCard = null
var selected_card_prev_z = null


var title: String = "big title!"

#var enemies: EnemyDb.EnemyData = EnemyDb.get_enemy("badboy")
var enemies_data: Array[EnemyDB.EnemyData]
var player_deck: CardDB.DeckPlayable
@onready var world_root: Node2D = $World
@onready var ui_layer: Control = $UI
@onready var background: Sprite2D = $Background

var deck_hand: Node2D
var enemies: Array[NodeEnemy]
var player: NodePlayer


###############
####Builtin####
###############
func _ready() -> void:
	add_to_group("encounter")
	connect_signals()
	attach_enemies()
	attach_deck_hand()
	_layout()
	
	
	
	
func _process(delta: float) -> void:
	_card_movement(delta)
	for enemy in enemies:
		if enemy.stats.health <= 0:
			enemies.erase(enemy)
			enemy.queue_free()
	
	
	
################
####GAMEPLAY####
################

func do_enemies_turn() -> void:
	for enemy in enemies:
		enemy.take_turn()	

func _on_card_clicked(card: NodeCard) -> void:
	print("Encounter detected clicked card:", card.card_info.name)
	if (selected_card == card):
		clear_selected_card()
		return
	selected_card = card
	selected_card_home_pos = card.global_position
	selected_card_prev_z = selected_card.z_index
	selected_card.z_index = 1000
	print("Selected card: ", selected_card.card_info.name)
	

func _on_enemy_clicked(enemy: NodeEnemy):
	print("Enemey has been clicked!")
	print(enemy.stats.name)
	if (selected_card == null):
		return
	EventBus.card_played.emit(player, selected_card, enemy)
	
func _on_card_played(player: NodePlayer, card: NodeCard, enemy: NodeEnemy):
	print("The card: " , card.name , " has been played by: ", player.player_name)
	if enemy:
		print("on Enemy: ", enemy.name)
	
	if player.mana >= card.card_info.cost_mana:
		player.mana -= card.card_info.cost_mana
		card.cast(player, enemy)
	else:
		print("NOT ENOUGH MANA")
		
	selected_card = null
	deck_hand.refresh_layout()
	

func _on_playable_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true: #if left mouse down
			if not selected_card == null && selected_card.card_info.needs_target == false:
				EventBus.card_played.emit(player, selected_card, null)
		if event.button_index == 2 and event.pressed == true:
			clear_selected_card()

func _on_end_turn_pressed() -> void:
	do_enemies_turn()
	deck_hand.discard_hand()
	deck_hand.draw_hand()
	#deck_hand.print_status()
	deck_hand.render_hand()
	player.end_turn()
	
	
func clear_selected_card() -> void:
		selected_card.global_position = selected_card_home_pos
		selected_card.z_index = selected_card_prev_z
		selected_card = null

######################
####UTILITY/SETUP#####
######################
func attach_enemies()-> void:
	var scene_enemy = preload("res://scenes/enemy.tscn")
	
	var enemy: Node2D
	for enemy_data in enemies_data:
		enemy = scene_enemy.instantiate()
		enemy.setup_enemy(enemy_data)
		enemy.player = player
		world_root.add_child(enemy)
		enemies.push_back(enemy)

func connect_signals()-> void:
	EventBus.card_clicked.connect(_on_card_clicked)
	EventBus.enemy_clicked.connect(_on_enemy_clicked)
	EventBus.card_played.connect(_on_card_played)
	get_viewport().size_changed.connect(_layout)

func attach_deck_hand()-> void:
	var scene_deck_hand = preload("res://scenes/deck_hand.tscn")
	deck_hand = scene_deck_hand.instantiate()
	
	deck_hand.deck_reference = player_deck
	
	world_root.add_child(deck_hand)
	

##############
####VISUAL####
##############


func _card_movement(delta: float) -> void:
	if selected_card == null:
		return

	var anchor := Vector2.ZERO
	if selected_card:
		anchor = selected_card_home_pos
		
	var mouse := get_viewport().get_mouse_position()
	var raw_offset := mouse - anchor
	# Keep it mostly above the hand and not below
	raw_offset.y = min(raw_offset.y, 0.0)

	var target_offset := _soft_box_offset(raw_offset, CARD_DRAG_BOX_HALF, CARD_DRAG_SOFTNESS)
	var target_pos := anchor + target_offset

	# Smooth follow (frame-rate independent)
	var t := 1.0 - exp(-CARD_DRAG_SPEED * delta)
	selected_card.global_position = selected_card.global_position.lerp(target_pos, t)
	

func _layout() -> void:
	var screen := get_viewport().get_visible_rect().size
	
	var enemy_spacing = 100.0
	var start_x = screen.x * 0.75 - (enemy_spacing * (enemies.size() - 1) / 2.0)
	
	for i in range(enemies.size()):
		enemies[i].global_position = Vector2(start_x + i * enemy_spacing, screen.y * ENEMY_Y_FRAC)
		
	player.global_position = Vector2(300, screen.y * ENEMY_Y_FRAC)
	deck_hand.position = Vector2(screen.x * 0.5, screen.y - HAND_Y_FROM_BOTTOM)


func _center_background() -> void:
	if background.texture == null:
		return

	background.centered = true

	var view_size := get_viewport_rect().size
	var tex_size := background.texture.get_size()

	background.position = view_size * 0.5

	# Fill screen (may crop). Use min() instead if you want "fit inside" with letterboxing.
	var s: float = max(view_size.x / tex_size.x, view_size.y / tex_size.y)
	background.scale = Vector2(s, s)


func set_background(texture_path: String) -> void:
	if background == null:
		print("BACKGROUND IS NULL")
	background.texture = load(texture_path)
	_center_background()
	
	
func _soft_box_offset(raw: Vector2, half: Vector2, softness: float) -> Vector2:
	# 1) Hard clamp to the box
	var clamped := Vector2(
		clamp(raw.x, -half.x, half.x),
		clamp(raw.y, -half.y, half.y)
	)

	# 2) Soft slowdown near the edges (nonlinear compression)
	# Convert each axis to [-1..1], apply ease, convert back.
	var nx := 0.0 if half.x == 0.0 else clamped.x / half.x
	var ny := 0.0 if half.y == 0.0 else clamped.y / half.y

	# "ease out" as |n| approaches 1.0
	# mix linear with cubic based on softness


	nx = _ease_axis(nx, softness)
	ny = _ease_axis(ny, softness)


	return Vector2(nx * half.x, ny * half.y)
	

func _ease_axis(n: float, softness: float) -> float:
	var a = abs(n)
	var eased := 1.0 - pow(1.0 - a, 3.0) # cubic ease-out
	var mixed = lerp(a, eased, softness)
	return sign(n) * mixed
