extends Node2D
signal cards_picked(cards: Array[CardDB.CardData])
@onready var ui_layer: Control = $UI
@onready var grid: GridContainer = $UI/ScrollContainer/grid
@onready var overlay: ColorRect = $UI/overlay
@onready var titlenode: Label = $UI/Title

var title = "Select a card"
var pick_count = 1
var skippable = false
var selected_cards: Array[CardDB.CardData] = []
var selected_controls: Array[Control] = [] # Objects that represent a card


func setup_picker(cards: Array[CardDB.CardData], p_title: String, p_pick_count: int, p_skippable: bool):
	title = p_title
	pick_count = p_pick_count
	skippable = p_skippable
	titlenode.text = title
	for card in cards:
		var control = Control.new()
		var texture_rect = TextureRect.new()
		control.custom_minimum_size = Vector2(200, 280)
		
		texture_rect.texture = load(card.texture_path)
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		#control.scale = Vector2(5,5)
		control.add_child(texture_rect)
		
		_add_card_labels(control, card)
		
		grid.add_child(control)
		control.gui_input.connect(_on_card_clicked.bind(control, card))

func _add_card_labels(control: Control, card: CardDB.CardData) -> void:
	# Title
	var title_label = Label.new()
	title_label.text = card.name
	title_label.position = Vector2(75, 157)
	title_label.size = Vector2(10, 10)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.add_theme_constant_override("outline_size", 8)
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	title_label.add_theme_font_size_override("font_size", 14)
	control.add_child(title_label)

	# Description
	var clip_box = Control.new()
	clip_box.position = Vector2(70, 180)
	clip_box.size = Vector2(120, 80)        # this is your hard boundary
	clip_box.clip_contents = false         # clips anything inside to this box
	clip_box.mouse_filter = Control.MOUSE_FILTER_PASS
	
	var desc_label = Label.new()
	desc_label.text = card.description
	desc_label.position = Vector2(0, 0)     # position relative to clip_box now
	desc_label.size = Vector2(150, 100)
	desc_label.set_deferred("size", Vector2(150, 100))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	desc_label.add_theme_color_override("font_color", Color.WHITE)
	desc_label.add_theme_constant_override("outline_size", 8)
	desc_label.add_theme_color_override("font_outline_color", Color.BLACK)
	desc_label.add_theme_font_size_override("font_size", 14)

	clip_box.add_child(desc_label)
	control.add_child(clip_box)

	# Cost
	var cost_label = Label.new()
	cost_label.text = str(card.cost_mana)
	cost_label.position = Vector2(25, 5)
	cost_label.size = Vector2(90, 0)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	cost_label.add_theme_color_override("font_color", Color.WHITE)
	cost_label.add_theme_constant_override("outline_size", 8)
	cost_label.add_theme_color_override("font_outline_color", Color.BLACK)
	cost_label.add_theme_font_size_override("font_size", 18)
	control.add_child(cost_label)

func _on_card_clicked(event: InputEvent, control: Control, card: CardDB.CardData):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed == true:
		if selected_controls.has(control):
			selected_controls.erase(control)
			selected_cards.erase(card)
			control.modulate = Color.WHITE
		else:
			if selected_controls.size() < pick_count:
				selected_controls.append(control)
				selected_cards.append(card)
				control.modulate = Color.GREEN

func _ready() -> void:
	pass

func _process(delta: float) -> void:
		
	pass

func _on_button_pressed() -> void:
	cards_picked.emit(selected_cards)
	queue_free()
