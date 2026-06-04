extends Control

var data: IconDB.IconData
var description_above: bool = false


func setup(icon_data: IconDB.IconData, above: bool = false) -> void:
	description_above = above
	data = icon_data
	$sprite.texture = load(data.texture)
	$tooltip/description.text = data.description
	$tooltip.hide()
	_position_description()

func _position_description() -> void:
	var tooltip = $iconbody/tooltip
	if description_above:
		tooltip.position.y -= 60

func _on_mouse_entered() -> void:
	$tooltip.show()

func _on_mouse_exited() -> void:
	$tooltip.hide()

func icon_scale(scale_size: Vector2):
	self.scale = scale_size
	$sprite.scale = scale_size
	var x_scaled = custom_minimum_size.x * scale_size.x
	var y_scaled = custom_minimum_size.y * scale_size.y
	print("x_scaled = ", x_scaled)
	custom_minimum_size = Vector2(x_scaled, y_scaled)


func update_count(count: int) -> void:
	if count > 1:
		$count.text = str(count)
		$count.show()
	else:
		$count.hide()
