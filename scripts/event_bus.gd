extends Node
#signal card_played(card: CardDB.CardData)
signal card_clicked(card: NodeCard)
signal enemy_clicked(enemy: NodeEnemy)
signal card_played(card: NodeCard, enemy: NodeEnemy)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
