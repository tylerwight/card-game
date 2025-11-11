extends Node2D

var active_encounter: Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var active_encounter = get_node("/root/Encounter")
	if active_encounter:
		print("Deck found encounter")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
