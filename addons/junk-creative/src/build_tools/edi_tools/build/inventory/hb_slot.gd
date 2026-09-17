extends PanelContainer

## Thumbnail needs to be updated by tool
signal updated

## To Switch block
signal clicked


@export_group("Internal References")
@export var texture_thumbnail: TextureRect


## The block registry index for this hotbar
var block_index: int:
	get:
		return block_index
	set(value):
		block_index = value
		updated.emit()
		return


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			clicked.emit()


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is int


func _drop_data(at_position: Vector2, data: Variant) -> void:
	block_index = data
