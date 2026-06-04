extends Node2D
class_name NodePlayer

var player_deck: Array[CardDB.CardData]
var player_effects: Array[PlayerEffects.PlayerEffect]
# Called when the node enters the scene tree for the first time.
var hp_label: Label
var health := 100
var max_hp := 100
var player_name := "Player 1"
var block := 0
var mana := 3
var mana_max := 3
var hp_loss_count := 0
var player_effect_container: HFlowContainer


var mana_label: Label
var block_label: Label
var hp_bar: ProgressBar
var hp_bar_label: Label
var hp_bar_display_value: float = 0.0
const HP_BAR_SPEED := 5.0
const MOVE_SPEED := 12.0
var target_pos := Vector2(0,0)
var home_pos := Vector2(0,0)
var sprite: AnimatedSprite2D
var is_attacking := false
var is_dead := false
const ICON_SCALE := Vector2(0.5, 0.5)


@onready var encounter := Main.get_tree().get_first_node_in_group("encounter")

func setup_player() -> void:
	sprite = NodeMain.build_animated_sprite()
	sprite.flip_h = false
	
	var idle_tex: Texture2D = load("res://assets/player/idle.png")
	NodeMain.add_animation(sprite, idle_tex, 140, 140, 11, "idle")
	var attack_tex: Texture2D = load("res://assets/player/attack.png")
	NodeMain.add_animation(sprite, attack_tex, 140, 140, 6, "attack", 8.0, false)
	var death_tex: Texture2D = load("res://assets/player/death.png")
	NodeMain.add_animation(sprite, death_tex, 140, 140, 9, "death", 8.0, false)
	var hit_tex: Texture2D = load("res://assets/player/hit.png")
	NodeMain.add_animation(sprite, hit_tex, 140, 140, 4, "hit", 8.0, false)
	
	add_child(sprite)
	sprite.play("idle")
	sprite.animation_finished.connect(_on_animation_finished)
	
	self.scale += Vector2(1, 1)
	#_setup_hp_label()
	#_update_hp_label()
	_setup_mana_label()
	#_update_mana_label()
	_setup_block_label()
	_update_block_label()
	_setup_hp_bar()
	

func get_damage(amount: int) -> int:
	var damage_dict = {"value": amount} # make a dictionary to pass by reference
	for effect in player_effects:
		effect.process_attacked_player(encounter, damage_dict)
	amount = damage_dict["value"]
		
	return amount

func damage(amount: int) -> void:
	
	amount = get_damage(amount)
	var block_used: int = min(block, amount)
	block -= block_used

	var hp_damage: int = amount - block_used
	
	if hp_damage > 0:
		health -= hp_damage
	
	hp_loss_count += 1
	print("PLAYER HP DOWN : ", hp_damage, "  hp_loss_count: = ", hp_loss_count)
	encounter.deck_hand.update_card_labels()

func remove_hp(amount: int) -> void:
	#ignore block and player effects
	health -= amount

func block_add(amount: int) -> void:
	block = block + amount
	
	
func apply_weak(amount: int) -> void:
	var found_weak = false
	
	for effect in player_effects:
		if effect is PlayerEffects.WeakEffect:
			effect.weak += amount
			found_weak = true
	
	if found_weak == false:
		var tmp = PlayerEffects.WeakEffect.new()
		tmp.weak += amount
		player_effects.append(tmp)
		
	refresh_icons()
	
func apply_strength(amount: int) -> void:
	var found_str = false
	
	for effect in player_effects:
		if effect is PlayerEffects.StrengthEffect:
			effect.strength += amount
			found_str = true
	
	if found_str == false:
		var tmp = PlayerEffects.StrengthEffect.new()
		tmp.strength += amount
		player_effects.append(tmp)
		
	refresh_icons()

func get_strength() -> int:
	for effect in player_effects:
		if effect is PlayerEffects.StrengthEffect:
			return effect.strength
	return 0


func apply_vulnerable(amount: int) -> void:
	var found_vulnerable = false
	for effect in player_effects:
		if effect is PlayerEffects.VulnerableEffect:
			effect.vulnerable += amount
			found_vulnerable = true
			
	if found_vulnerable == false:
		var tmp = PlayerEffects.VulnerableEffect.new()
		tmp.vulnerable += amount
		player_effects.append(tmp)
		
	refresh_icons()
	
	
func end_turn() -> void:
	for effect in player_effects.duplicate():
		effect.process_end_player(encounter, null)
		if effect.deleteme == true:
			player_effects.erase(effect)
		
	if block > 0:
		block = 0 
	mana = mana_max
	
	
func start_turn() -> void:
	for effect in player_effects.duplicate():
		effect.process_start_player(encounter)
		if effect.deleteme == true:
			player_effects.erase(effect)
	refresh_icons()


func end_combat() -> void:
	hp_loss_count = 0
	
func _ready() -> void:
	setup_player()
	print("PLAYER NODE NAME IS: ", self.name)
	target_pos = position
	home_pos = position
	print("at pos:", target_pos)
	player_effect_container = HFlowContainer.new()
	player_effect_container.name = "player_effect_container"
	player_effect_container.position = Vector2(-50, 30)  # adjust to sit below your player sprite
	player_effect_container.size = Vector2(100, 50)     # width controls when icons wrap
	player_effect_container.alignment = FlowContainer.ALIGNMENT_CENTER
	add_child(player_effect_container)
	apply_strength(2)
	apply_vulnerable(2)
	apply_weak(2)
	EventBus.top_of_round.emit()
	
func _process(delta: float) -> void:
	#_update_hp_label()
	#_update_mana_label()
	_update_block_label()
	_update_hp_bar_label(delta)
	#var t := 1.0 - exp(-MOVE_SPEED * delta)
	#position = position.lerp(target_pos, t)
	
	if health <= 0 and not is_dead:
		is_dead = true
		sprite.play("death")
	
#func add_icon(id: String) -> void:
	#if has_icon(id):
		#return
	#var icon = IconDB.create_icon_node(id)
	#icon.icon_scale(ICON_SCALE)
	#player_effect_container.add_child(icon)

func remove_icon(id: String) -> void:
	for child in player_effect_container.get_children():
		if child.data.id == id:
			child.queue_free()
			return

func has_icon(id: String) -> bool:
	for child in player_effect_container.get_children():
		if child.data.id == id:
			return true
	return false

func refresh_icons() -> void:
	# Build a map of what effects currently exist and their values
	var effect_map: Dictionary = {}
	for effect in player_effects:
		if effect is PlayerEffects.StrengthEffect:
			effect_map["strength"] = effect.strength
		elif effect is PlayerEffects.WeakEffect:
			effect_map["weak"] = effect.weak
		elif effect is PlayerEffects.VulnerableEffect:
			effect_map["vulnerable"] = effect.vulnerable

	# Remove icons that no longer have an effect
	for child in player_effect_container.get_children():
		if not effect_map.has(child.data.id):
			child.queue_free()

	# Add or update icons that should exist
	for id in effect_map:
		if not has_icon(id):
			var icon = IconDB.create_icon_node(id)
			icon.icon_scale(ICON_SCALE)
			player_effect_container.add_child(icon)
		# update count whether new or existing
		# use call_deferred since queue_free above is deferred
		var icon = get_icon_node(id)
		if icon:
			icon.update_count(effect_map[id])

func get_icon_node(id: String) -> Control:
	for child in player_effect_container.get_children():
		if child.data.id == id:
			return child
	return null



		
func _setup_mana_label() -> void:
	mana_label = Label.new()
	mana_label.name = "ManaLabel"
	mana_label.z_index = 1000 # draw on top of enemy
	mana_label.position = Vector2(-100, 100) # tweak for your sprite size
	mana_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Optional: make it readable
	mana_label.add_theme_color_override("font_color", Color.WHITE)
	mana_label.add_theme_constant_override("outline_size", 4)
	mana_label.add_theme_color_override("font_outline_color", Color.BLACK)
	

	add_child(mana_label)


		
		
		
func _setup_block_label() -> void:
	block_label = Label.new()
	block_label.name = "HpLabel"
	block_label.z_index = 1000 # draw on top of enemy
	block_label.position = Vector2(-10, 10) # tweak for your sprite size
	block_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Optional: make it readable
	block_label.add_theme_color_override("font_color", Color.WHITE)
	block_label.add_theme_constant_override("outline_size", 4)
	block_label.add_theme_color_override("font_outline_color", Color.BLACK)

	block_label.add_theme_font_size_override("font_size", 10)

	add_child(block_label)
	
func _update_block_label() -> void:
	if block_label:
		block_label.text = "BLK: %d" % block
		
		

func _setup_hp_bar() -> void:
	hp_bar = ProgressBar.new()
	hp_bar.name = "HpBar"
	hp_bar.z_index = 900
	hp_bar.position = Vector2(-20, 20)
	hp_bar.call_deferred("set_size", Vector2(40, 4)) # defer it cause otherwise some size stuff doesn't work
	hp_bar.min_value = 0
	hp_bar.max_value = max_hp
	hp_bar.value = health
	hp_bar.show_percentage = false  # we'll draw our own text
	hp_bar.z_as_relative = false

	#Colors
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.8, 0.1, 0.1)
	fill_style.border_color = Color.BLACK
	fill_style.set_border_width_all(1)
	hp_bar.add_theme_stylebox_override("fill", fill_style)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2)
	bg_style.border_color = Color.BLACK
	bg_style.set_border_width_all(1)
	hp_bar.add_theme_stylebox_override("background", bg_style)

	#Label on top of the bar
	hp_bar_label = Label.new()
	hp_bar_label.z_index = 900
	hp_bar_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	hp_bar_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_bar_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_bar_label.add_theme_color_override("font_color", Color.WHITE)
	hp_bar_label.add_theme_constant_override("outline_size", 3)
	hp_bar_label.add_theme_color_override("font_outline_color", Color.BLACK)
	hp_bar_label.add_theme_font_size_override("font_size", 6)
	hp_bar_label.position = Vector2(0, 5)
	hp_bar_label.z_as_relative = false
	hp_bar.add_child(hp_bar_label)

	add_child(hp_bar)

func _update_hp_bar_label(delta: float) -> void:
	if hp_bar:
		hp_bar.value = health
		hp_bar_display_value = lerp(hp_bar_display_value, float(health), 1.0 - exp(-HP_BAR_SPEED * delta))
		hp_bar.value = hp_bar_display_value
		hp_bar_label.text = "%d / %d" % [health, max_hp]
		
		
		
		
func attack_move() -> void:
	is_attacking = true
	var tween = create_tween()
	tween.tween_property(self, "position", home_pos + Vector2(500, 0), 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", home_pos, 0.3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await tween.finished
	is_attacking = false


func _on_animation_finished() -> void:
	if not is_dead:
		sprite.play("idle")
