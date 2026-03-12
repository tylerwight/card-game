extends Node2D
class_name NodePlayer

var player_deck: Array[CardDB.CardData]
# Called when the node enters the scene tree for the first time.
var hp_label: Label
var health := 100
var max_hp := 100
var player_name := "Player 1"
var block := 0
var mana := 3
var mana_max := 3
var vulnerable := 0
var mana_label: Label
var block_label: Label
var hp_bar: ProgressBar
var hp_bar_label: Label
var hp_bar_display_value: float = 0.0
const HP_BAR_SPEED := 5.0

var sprite: AnimatedSprite2D

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
	_setup_hp_label()
	_update_hp_label()
	_setup_mana_label()
	_update_mana_label()
	_setup_block_label()
	_update_block_label()
	_setup_hp_bar()
	

func damage(amount: int) -> void:
	if vulnerable > 0:
		amount = amount * 1.5
		
	var block_used: int = min(block, amount)
	block -= block_used

	var hp_damage: int = amount - block_used
	if hp_damage > 0:
		health -= hp_damage

func block_add(amount: int) -> void:
	block = block + amount
	
	
func end_turn() -> void:
	if block > 0:
		block = 0 
	mana = mana_max
	if vulnerable > 0:
		vulnerable -= 1

func _ready() -> void:
	setup_player()
	print("PLAYER NODE NAME IS: ", self.name)
	
func _process(delta: float) -> void:
	_update_hp_label()
	_update_mana_label()
	_update_block_label()
	_update_hp_bar_label(delta)
	
	if health <= 0:
		print("DEAD DEAD DEAD")
	
func _setup_hp_label() -> void:
	hp_label = Label.new()
	hp_label.name = "HpLabel"
	hp_label.z_index = 1000 # draw on top of enemy
	hp_label.position = Vector2(-100, -210) # tweak for your sprite size
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var screen := get_viewport().get_visible_rect().size

	# Optional: make it readable
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	hp_label.add_theme_constant_override("outline_size", 4)
	hp_label.add_theme_color_override("font_outline_color", Color.BLACK)

	add_child(hp_label)

func _update_hp_label() -> void:
	if hp_label:
		hp_label.text = "HP: %d" % health
		
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

func _update_mana_label() -> void:
	if mana_label:
		mana_label.text = "Mana: %d/%d" % [mana, mana_max]
		
		
		
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
		
		
		
		
		


func _on_animation_finished() -> void:
	sprite.play("idle")
