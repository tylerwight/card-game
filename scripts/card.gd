extends Node2D


func _ready() -> void:
	var sprite:= Sprite2D.new()
	sprite.texture = load("res://assets/test_card.png")
	add_child(sprite)


func _process(delta: float) -> void:
	pass
