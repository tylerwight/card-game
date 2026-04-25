extends Node2D
class_name NodeCard

var card_info: CardDB.CardData = CardDB.get_card("strike")
var deck_hand: NodeDeckHand
var encounter: Node2D
var desc_label: RichTextLabel
var cost_label: Label
var title_label: RichTextLabel
var playing:= false

const BASE_SCALE := Vector2(2.0, 2.0)
const HOVER_SCALE := Vector2(2.5, 2.5)
const SCALE_SPEED := 12.0
const HOVER_LIFT_AMOUNT := 110.0  # pixels to rise on hover

var lift_offset := Vector2.ZERO
var target_lift_offset := Vector2.ZERO
var home_position := Vector2.ZERO

var base_z_index := 0
var target_scale := BASE_SCALE


func setup_card(card: CardDB.CardData):
	card_info = card

func _ready() -> void:
	$cardbody.input_pickable = true
	var sprite:= Sprite2D.new()
	deck_hand = get_parent()
	#encounter = get_parent().get_parent().get_parent()
	encounter = get_tree().get_first_node_in_group("encounter")
	if not (deck_hand or encounter):
		print("couldn't find deck hand or encounter")
	
	sprite.texture = load(card_info.texture_path)
	add_child(sprite)
	self.scale  = BASE_SCALE
	_setup_desc_label()
	_setup_cost_label()
	_update_labels()



func cast(player: NodePlayer, enemy: NodeEnemy) -> void:
	card_info.cast(self, player, enemy)

func card_playable(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> bool:
	if card_info.card_playable(card, player, enemy)["playable"] == true:
		return true
	else:
		return false
		

func card_playable_message(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> String:
	return card_info.card_playable(card, player, enemy)["message"]

func discard():
	print("trying to discard: ", card_info.name)
	deck_hand.discard.add_card_to_deck(card_info)
	deck_hand.hand.remove_card(card_info)
	self.call_deferred("queue_free")

func exhaust():
	deck_hand.exhausted.add_card_to_deck(card_info)
	deck_hand.hand.remove_card(card_info)
	self.call_deferred("queue_free")
	
	for effect in encounter.player.player_effects.duplicate():
		effect.process_exhaust_player(encounter)

func remove():
	deck_hand.hand.remove_card(card_info)
	self.call_deferred("queue_free")

func move_to_top_of_draw_pile():
	print("trying to move to top of draw pile: ", card_info.name)
	deck_hand.deck.add_card_to_deck_front(card_info)
	deck_hand.hand.remove_card(card_info)
	self.call_deferred("queue_free")


func _process(delta: float) -> void:
	var t := 1.0 - exp(-SCALE_SPEED * delta)
	scale = scale.lerp(target_scale, t)
	lift_offset = lift_offset.lerp(target_lift_offset, t)
	if encounter.selected_card != self:
		position = home_position + lift_offset

func _on_cardbody_mouse_entered() -> void:
	target_scale = HOVER_SCALE
	target_lift_offset = Vector2(0, -HOVER_LIFT_AMOUNT)
	base_z_index = z_index
	z_index = 1001

func _on_cardbody_mouse_exited() -> void:
	if encounter.selected_card != self:
		target_scale = BASE_SCALE
		z_index = base_z_index
	target_lift_offset = Vector2.ZERO
	
func upgrade() -> void:
	card_info.upgrade()
	_update_desc_label(card_info.get_description(), card_info.name)
	_update_cost_label()

func _on_cardbody_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true: #if left mouse down
			print("trying to send event")
			EventBus.card_clicked.emit(self)
	
	
	
func _setup_desc_label() -> void:
	#desc
	desc_label = RichTextLabel.new()
	desc_label.bbcode_enabled = true
	desc_label.fit_content = true
	desc_label.name = "DescLabel"
	#desc_label.z_index = 1000 # draw on top of enemy
	desc_label.position = Vector2(-35, 20) # tweak for your sprite size
	desc_label.size = Vector2(75, 0)  # set width of text box
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	desc_label.add_theme_color_override("font_color", Color.WHITE)
	desc_label.add_theme_constant_override("outline_size", 4)
	desc_label.add_theme_color_override("font_outline_color", Color.BLACK)
	desc_label.add_theme_font_size_override("normal_font_size", 7)
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(desc_label)
	
	#title
	title_label = RichTextLabel.new()
	title_label.bbcode_enabled = true
	title_label.fit_content = true
	title_label.name = "TitleLabel"
	#title_label.z_index = 1000 # draw on top of enemy
	title_label.position = Vector2(-33, 6) # tweak for your sprite size
	title_label.size = Vector2(80, 0)  # set width of text box
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.add_theme_constant_override("outline_size", 4)
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	title_label.add_theme_font_size_override("normal_font_size", 8)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(title_label)
	
func _setup_cost_label() -> void:
	cost_label = Label.new()
	cost_label.name = "CostLabel"
	#cost_label.z_index = 1000 # draw on top of enemy
	cost_label.position = Vector2(-78, -63) # tweak for your sprite size
	cost_label.size = Vector2(90, 0)  # set width of text box
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Optional: make it readable
	cost_label.add_theme_color_override("font_color", Color.WHITE)
	cost_label.add_theme_constant_override("outline_size", 4)
	cost_label.add_theme_color_override("font_outline_color", Color.BLACK)
	cost_label.add_theme_font_size_override("font_size", 8)

	add_child(cost_label)

func _update_labels() -> void:
	_update_desc_label(card_info.get_description(), card_info.name)
	_update_cost_label()

func _update_cost_label() -> void:
	if cost_label:
		cost_label.text = str(card_info.get_cost(self, encounter.player))

func _update_desc_label(desc: String, title: String) -> void:
	if desc_label:
		desc_label.text = desc
		title_label.text = title
		#desc_label.text = card_info.description
		#title_label.text = card_info.name
