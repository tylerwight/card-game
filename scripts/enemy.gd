extends Node2D
class_name NodeEnemy
var stats: EnemyDB.EnemyData = EnemyDB.get_enemy("badboy")
var hp_label: Label
var hitting_label: Label
var player: NodePlayer

var hp_bar: ProgressBar
var hp_bar_label: Label


const BASE_SCALE := Vector2(2.0, 2.0)
const HOVER_SCALE := Vector2(2.5, 2.5)
const SCALE_SPEED := 12.0

var max_hp = 0

func setup_enemy(data: EnemyDB.EnemyData) -> void:
	stats = data
	max_hp = stats.health
	print("I am enemy: ", data.name)
	
	
	var texture: Texture2D = load(stats.texture_path +  "idle.png")
	var sprite := NodeMain.build_sprite_animation(texture, 100, 100, 6, "idle")
	sprite.flip_h = true
	add_child(sprite)
	stats.behavior.randomize()
	self.scale  = BASE_SCALE




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$enemybody.input_pickable = true
	_setup_hp_label()
	_update_hp_label()
	_setup_hitting_label()
	_update_hitting_label()
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_hp_label()
	if stats.health <= 0:
		print("ENEMY DEAD")
		self.queue_free()
	
	
func _setup_hp_label() -> void:
	hp_bar = ProgressBar.new()
	hp_bar.name = "HpBar"
	hp_bar.z_index = 900
	hp_bar.position = Vector2(-20, 20)
	hp_bar.custom_minimum_size = Vector2(0, 0)
	hp_bar.call_deferred("set_size", Vector2(40, 4))
	hp_bar.min_value = 0
	hp_bar.max_value = max_hp
	hp_bar.value = stats.health
	hp_bar.show_percentage = false  # we'll draw our own text

	# Color the fill red
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.8, 0.1, 0.1)
	hp_bar.add_theme_stylebox_override("fill", fill_style)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2)
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
	hp_bar.add_child(hp_bar_label)

	add_child(hp_bar)

func _update_hp_label() -> void:
	if hp_bar:
		hp_bar.value = stats.health
		hp_bar_label.text = "%d / %d" % [stats.health, max_hp]
		
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
