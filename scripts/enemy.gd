extends Node2D
class_name NodeEnemy
var stats: EnemyDB.EnemyData = EnemyDB.get_enemy("badboy")
var hp_label: Label
var hitting_label: Label
var player: NodePlayer

var hp_bar: ProgressBar
var hp_bar_label: Label
var hp_bar_display_value: float = 0.0
const HP_BAR_SPEED := 5.0

const BASE_SCALE := Vector2(2.0, 2.0)
const HOVER_SCALE := Vector2(2.5, 2.5)
const SCALE_SPEED := 12.0

var is_attacking = false
var home_pos := Vector2(0,0)
var max_hp = 0
var sprite: AnimatedSprite2D
var is_dead := false
@onready var active_encounter: NodeEncounter = get_tree().get_first_node_in_group("encounter")

func setup_enemy(data: EnemyDB.EnemyData) -> void:
	stats = data
	max_hp = stats.health
	print("I am enemy: ", data.name)
	
	
	sprite = NodeMain.build_animated_sprite()
	var idle_tex: Texture2D = load(stats.texture_path +  "idle.png")
	NodeMain.add_animation(sprite, idle_tex, 100, 100, 6, "idle")
	var hit_tex: Texture2D = load(stats.texture_path +  "hit.png")
	NodeMain.add_animation(sprite, hit_tex, 100, 100, 4, "hit", 5.0, false)
	var attack_tex: Texture2D = load(stats.texture_path +  "attack.png")
	NodeMain.add_animation(sprite, attack_tex, 100, 100, 6, "attack", 5.0, false)
	var death_tex: Texture2D = load(stats.texture_path +  "death.png")
	NodeMain.add_animation(sprite, death_tex, 100, 100, 4, "death", 5.0, false)
	
	sprite.flip_h = true
	add_child(sprite)
	sprite.play("idle")
	sprite.animation_finished.connect(_on_animation_finished)
	
	stats.roll_intents()
	self.scale  = BASE_SCALE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$enemybody.input_pickable = true
	_setup_hp_label()
	_setup_hitting_label()
	_update_hitting_label()
	
	print("============= Home pos: ", home_pos, "E pos: ", position)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_hp_label(delta)
	
	if stats.health <= 0 and not is_dead:
		is_dead = true
		die()


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
	stats.roll_intents()
	_update_hitting_label()
	
func apply_vulnerable(amount: int) -> void:
	stats.vulnerable += amount

func apply_weak(amount: int) -> void:
	stats.weak += amount

#################
###Graphics
##################
func _on_animation_finished() -> void:
	if not is_dead:
		sprite.play("idle")
	
	
func _setup_hp_label() -> void:
	hp_bar = ProgressBar.new()
	hp_bar.name = "HpBar"
	hp_bar.z_index = 900
	hp_bar.position = Vector2(-20, 18)
	hp_bar.custom_minimum_size = Vector2(0, 0)
	hp_bar.call_deferred("set_size", Vector2(40, 4))
	hp_bar.min_value = 0
	hp_bar.max_value = max_hp
	hp_bar.value = stats.health
	hp_bar.show_percentage = false  # we'll draw our own text
	hp_bar.z_as_relative = false

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

func _update_hp_label(delta: float) -> void:
	if hp_bar:
		hp_bar_display_value = lerp(hp_bar_display_value, float(stats.health), 1.0 - exp(-HP_BAR_SPEED * delta))
		hp_bar.value = hp_bar_display_value
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
		
func die() -> void:
	sprite.play("death")
	await sprite.animation_finished
	await get_tree().create_timer(1.0).timeout
	active_encounter.clean_up_enemies()
		
		
func attack_move() -> void:
	is_attacking = true
	var tween = create_tween()
	tween.tween_property(self, "position", home_pos - Vector2(500, 0), 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", home_pos, 0.3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await tween.finished
	is_attacking = false
