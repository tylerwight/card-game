extends Node2D
class_name NodePlayer

var player_deck: Array[CardDB.CardData]
# Called when the node enters the scene tree for the first time.

var health := 100
var player_name := "Player 1"
var block := 0

func setup_player() -> void:
	print("I am player:")
	var texture: Texture2D = load("res://assets/player/idle.png")
	var sprite := NodeMain.build_sprite_animation(texture, 128, 128, 4, "idle")
	sprite.flip_h = false
	add_child(sprite)


func damage(amount: int) -> void:
	health = health - amount

func block_add(amount: int) -> void:
	block = block + amount

func _ready() -> void:
	setup_player()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
