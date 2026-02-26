extends Node2D
class_name NodeEnemy
var stats: EnemyDB.EnemyData = EnemyDB.get_enemy("badboy")
var hp_label: Label
var hitting_label: Label
var player: NodePlayer

func setup_enemy(data: EnemyDB.EnemyData) -> void:
	stats = data
	print("I am enemy: ", data.name)
	
	
	var texture: Texture2D = load(stats.texture_path)
	var sprite := NodeMain.build_sprite_animation(texture, 128, 128, 7, "idle")
	sprite.flip_h = true
	add_child(sprite)
	stats.behavior.randomize()
	self.scale += Vector2(1, 1)
	_setup_hp_label()
	_update_hp_label()
	_setup_hitting_label()
	_update_hitting_label()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$enemybody.input_pickable = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_hp_label()
	if stats.health <= 0:
		print("ENEMY DEAD")
		self.queue_free()
	
	
func _setup_hp_label() -> void:
	hp_label = Label.new()
	hp_label.name = "HpLabel"
	hp_label.z_index = 1000 # draw on top of enemy
	hp_label.position = Vector2(-40, 60) # tweak for your sprite size
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Optional: make it readable
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	hp_label.add_theme_constant_override("outline_size", 4)
	hp_label.add_theme_color_override("font_outline_color", Color.BLACK)

	hp_label.add_theme_font_size_override("font_size", 10)

	add_child(hp_label)

func _update_hp_label() -> void:
	if hp_label:
		hp_label.text = "HP: %d + vuln: %d" % [stats.health, stats.vulnerable]
		
func _setup_hitting_label() -> void:
	hitting_label = Label.new()
	hitting_label.name = "HpLabel"
	hitting_label.z_index = 1000 # draw on top of enemy
	hitting_label.position = Vector2(-40, -50) # tweak for your sprite size
	hitting_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Optional: make it readable
	hitting_label.add_theme_color_override("font_color", Color.WHITE)
	hitting_label.add_theme_constant_override("outline_size", 4)
	hitting_label.add_theme_color_override("font_outline_color", Color.BLACK)

	hitting_label.add_theme_font_size_override("font_size", 10)

	add_child(hitting_label)

func _update_hitting_label() -> void:
	if hitting_label:
		hitting_label.text = "Attacking: %d" % stats.behavior.actual_damage


func damage_melee(amount: int) -> void:
	print("enemy hp before: ", stats.health)
	if stats.vulnerable > 0:
		amount = amount * 1.5
	var block_used: int = min(stats.block, amount)
	stats.block -= block_used

	var hp_damage: int = amount - block_used
	if hp_damage > 0:
		stats.health -= hp_damage
	print("enemy hp after: ", stats.health)

func _on_enemybody_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true: #if left mouse down
			print("trying to send event")
			EventBus.enemy_clicked.emit(self)


func take_turn() -> void:
	stats.take_turn(player, self)
	stats.behavior.randomize()
	_update_hitting_label()
	
func apply_vulnerable(amount: int) -> void:
	stats.vulnerable += amount
