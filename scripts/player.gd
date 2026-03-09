extends Node2D
class_name NodePlayer

var player_deck: Array[CardDB.CardData]
# Called when the node enters the scene tree for the first time.
var hp_label: Label
var health := 100
var player_name := "Player 1"
var block := 0
var mana := 3
var mana_max := 3
var vulnerable := 0
var mana_label: Label
var block_label: Label

func setup_player() -> void:
	print("I am player:")
	var texture: Texture2D = load("res://assets/player/idle.png")
	var sprite := NodeMain.build_sprite_animation(texture, 140, 140, 11, "idle")
	sprite.flip_h = false
	add_child(sprite)
	self.scale += Vector2(1, 1)
	_setup_hp_label()
	_update_hp_label()
	_setup_mana_label()
	_update_mana_label()
	_setup_block_label()
	_update_block_label()
	

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
