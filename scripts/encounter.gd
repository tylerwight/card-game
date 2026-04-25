extends Node2D
class_name NodeEncounter
# Enemy clickable - done
# add card selection and playing
# add selecting enemies
#add text rendernig of things like HP, mana, etc.

const HAND_Y_FROM_BOTTOM := 75.0
const ENEMY_Y_FRAC := 0.601
const PLAYER_Y_FRAC:= 0.59
const CARD_DRAG_BOX_HALF := Vector2(100.0, 80.0)  # (left/right, up)
const CARD_DRAG_SPEED := 10.0                      # higher = snappier
const CARD_DRAG_SOFTNESS := 0.75                   # 0..1, higher = more slowdown near edge
const PLAYER_ATTACK_POS := Vector2(200, 200)
var selected_card_home_pos: Vector2 = Vector2.ZERO
var hp_label: Label
var mana_label: Label

var selected_card: NodeCard = null
var selected_card_prev_z = null
var hovered_enemy: NodeEnemy = null


var title: String = "big title!"

#var enemies: EnemyDb.EnemyData = EnemyDb.get_enemy("badboy")
var enemies_data: Array[EnemyDB.EnemyData]
var player_deck: CardDB.DeckPlayable
@onready var world_root: Node2D = $World
@onready var ui_layer: Control = $UI
@onready var background: Sprite2D = $Background

var deck_hand: NodeDeckHand
var enemies: Array[NodeEnemy]
var player: NodePlayer


###############
####Builtin/setup####
###############
func _ready() -> void:
	add_to_group("encounter")
	connect_signals()
	attach_enemies()
	attach_deck_hand()
	_layout()
	_setup_labels()
	
	
func clean_up_enemies() -> void:
	for enemy in enemies:
		if enemy.stats.health <= 0:
			enemies.erase(enemy)
			enemy.queue_free()
	
func _process(delta: float) -> void:
	_card_movement(delta)
	_update_labels()

	if enemies.size() <= 0:
		flash_message("YOU WIN", true, 2)
		
	if player.is_dead:
		flash_message("YOU LOSE", false, 2)
	
################
#####SIGNALS#####
#################
func _on_card_clicked(card: NodeCard) -> void:
	card.upgrade()
	#print("Encounter detected clicked card:", card.card_info.name)
	if (selected_card == card):
		clear_selected_card()
		return
	selected_card = card
	selected_card_home_pos = card.global_position
	selected_card_prev_z = selected_card.z_index
	selected_card.z_index = 1000
	#print("Selected card: ", selected_card.card_info.name)
	

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
	if card.playing == true:
		return
	if card.card_playable(card, player, enemy):
		player.mana -= card.card_info.get_cost(card, player)
		card.card_info.populate_damage_actual(self, card)
		#card.card_info.get_dynamic_desc()
		card.playing = true
		player.sprite.play("attack")
		player.attack_move()
		await player.sprite.animation_finished
		await card.cast(player, enemy)
		if enemy: enemy.sprite.play("hit")
		card.playing = false
	else:
		flash_message(card.card_playable_message(card, player, enemy), false)
		
	selected_card = null
	deck_hand.refresh_layout()
	print("After Card Played")
	print("\n ENEMY EFFECTS")
	for enem in enemies:
		Main.print_player_effects(enem.stats.player_effects)
	
	

func _on_playable_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true: #if left mouse down
			if not selected_card == null && selected_card.card_info.needs_target == false:
				EventBus.card_played.emit(player, selected_card, null)
		if event.button_index == 2 and event.pressed == true:
			clear_selected_card()

func _on_end_turn_pressed() -> void:
	await do_enemies_turn()
	refresh_hand()

	player.end_turn()
	print("After turn end")
	EventBus.top_of_round.emit()
	

func refresh_hand() -> void:
	deck_hand.discard_hand()
	deck_hand.draw_hand(true)
	deck_hand.render_hand()

func _on_enemy_hover_enter(enemy: NodeEnemy) -> void:
	hovered_enemy = enemy
	if selected_card:
		var true_dmg = get_true_damage(player, selected_card, hovered_enemy)
		print("TRUE DAMGE: ", true_dmg)
		selected_card._update_desc_label(selected_card.card_info.get_dynamic_desc(true_dmg), selected_card.card_info.name)

func _on_enemy_hover_exit(enemy: NodeEnemy) -> void:
	hovered_enemy = null
	for card in deck_hand.get_card_nodes():
		card._update_desc_label(card.card_info.get_description(), card.card_info.name)
		
func _top_of_round():
	print("#######NEW ROUND########")
	print("PLAYER EFFECTS")
	Main.print_player_effects(player.player_effects)
	print("\n ENEMY EFFECTS")
	for enemy in enemies:
		Main.print_player_effects(enemy.stats.player_effects)
		
	deck_hand.print_status()
		

################
####GAMEPLAY####
################


func get_true_damage(player: NodePlayer, card: NodeCard, enemy: NodeEnemy):
	card.card_info.populate_damage_actual(self, card)
	var total = enemy.get_damage(card.card_info.damage_actual)
	return total
	
	
func do_enemies_turn() -> void:
	for enemy in enemies:
		enemy.sprite.play("attack")
		enemy.attack_move()
		
		await enemy.sprite.animation_finished
		player.sprite.play("hit")
		enemy.take_turn()	
	return



func spawn_and_play_card(card_info: CardDB.CardData) -> void:
	var card = deck_hand.card_scene.instantiate()
	card.setup_card(card_info)
	card.card_info.discard_to_exhuast = true
	deck_hand.add_child(card)
	
	card.card_info.populate_damage_actual(self, card)
	card.playing = true
	player.sprite.play("attack")
	player.attack_move()
	await player.sprite.animation_finished
	
	var enemy = enemies.pick_random()
	card.cast(player, enemy)
	if enemy: enemy.sprite.play("hit")
	card.playing = false
	

	
func clear_selected_card() -> void:
	if selected_card:
		selected_card.target_scale = selected_card.BASE_SCALE
		selected_card.target_lift_offset = Vector2.ZERO
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
	EventBus.enemy_hover_enter.connect(_on_enemy_hover_enter)
	EventBus.enemy_hover_exit.connect(_on_enemy_hover_exit)
	EventBus.top_of_round.connect(_top_of_round)
	get_viewport().size_changed.connect(_layout)

func attach_deck_hand()-> void:
	var scene_deck_hand = preload("res://scenes/deck_hand.tscn")
	deck_hand = scene_deck_hand.instantiate()
	
	deck_hand.deck_reference = player_deck
	
	world_root.add_child(deck_hand)
	

##############
####VISUAL####
##############

func _setup_labels() -> void:
	_setup_hp_label()
	_setup_mana_label()
	
func _update_labels() -> void:
	_update_hp_label()
	_update_mana_label()

func _setup_hp_label() -> void:
	hp_label = Label.new()
	hp_label.name = "HpLabel"
	hp_label.z_index = 1000 # draw on top of enemy
	hp_label.position = Vector2(0, 0) # tweak for your sprite size
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	#var screen := get_viewport().get_visible_rect().size

	# Optional: make it readable
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	hp_label.add_theme_constant_override("outline_size", 4)
	hp_label.add_theme_color_override("font_outline_color", Color.BLACK)
	hp_label.add_theme_font_size_override("font_size", 25)

	add_child(hp_label)

func _setup_mana_label() -> void:
	mana_label = Label.new()
	mana_label.name = "ManaLabel"
	mana_label.z_index = 1000 # draw on top of enemy
	mana_label.position = Vector2(0, 650) # tweak for your sprite size
	mana_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Optional: make it readable
	
	mana_label.add_theme_color_override("font_color", Color.WHITE)
	mana_label.add_theme_constant_override("outline_size", 4)
	mana_label.add_theme_color_override("font_outline_color", Color.BLACK)
	mana_label.add_theme_font_size_override("font_size", 25)
	

	add_child(mana_label)

func _update_hp_label() -> void:
	if hp_label:
		hp_label.text = "HP: %d" % player.health
		
func _update_mana_label() -> void:
	if mana_label:
		mana_label.text = "Mana: %d/%d" % [player.mana, player.mana_max]

func _card_movement(delta: float) -> void:
	if selected_card == null:
		return

	var screen := get_viewport().get_visible_rect().size
	var target_pos:= Vector2(0,0)
	
	if selected_card.playing == true:
		
		target_pos = Vector2(screen.x * 0.5, screen.y * 0.25)
	else:
		target_pos = Vector2(screen.x * 0.5, screen.y * 0.76)

	var t := 1.0 - exp(-CARD_DRAG_SPEED * delta)
	selected_card.global_position = selected_card.global_position.lerp(target_pos, t)
	

func _layout() -> void:
	var screen := get_viewport().get_visible_rect().size
	
	var enemy_spacing = 150.0
	var start_x = screen.x * 0.75 - (enemy_spacing * (enemies.size() - 1) / 2.0)
	
	for i in range(enemies.size()):
		enemies[i].global_position = Vector2(start_x + i * enemy_spacing, screen.y * ENEMY_Y_FRAC)
		enemies[i].home_pos = enemies[i].position
		
	player.global_position = Vector2(250, screen.y * PLAYER_Y_FRAC)
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
	background.translate(Vector2(0, -100))


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
	
	
func flash_message(text: String, good: bool = true, linger: float = 1) -> void:
	# Container - auto-sizes to content
	var panel = PanelContainer.new()
	
	# Style the background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", style)
	panel.z_index = 2000
	add_child(panel)

	# Label
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color.YELLOW if good else Color.RED)
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	panel.add_child(label)

	# Wait one frame so the container has calculated its size before centering
	await get_tree().process_frame
	var screen := get_viewport().get_visible_rect().size
	panel.position = Vector2(
		screen.x * 0.5 - panel.size.x * 0.5,
		screen.y * 0.4
	)

	# Animate: fade in, hold, fade out
	var tween = create_tween()
	panel.modulate.a = 0.0
	tween.tween_property(panel, "modulate:a", 1.0, 0.15)
	tween.tween_interval(0.8 * linger)
	tween.tween_property(panel, "modulate:a", 0.0, 0.3 * linger)
	await tween.finished
	panel.queue_free()
