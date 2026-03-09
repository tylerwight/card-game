extends Node2D


@onready var ui_layer: Control = $UI
@onready var grid: GridContainer = $UI/grid

var title = "Select a card"
var pick_count = 1
var skippable = false

func setup_picker(cards: Array[CardDB.CardData], title: String, pick_count: int, skippable: bool):
	for card in cards:
		var control = Control.new()
		var texture_rect = TextureRect.new()
		control.custom_minimum_size = Vector2(100, 140)
		
		texture_rect.texture = load(card.texture_path)
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		control.add_child(texture_rect)

		grid.add_child(control)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
