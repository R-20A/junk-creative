#class_name InventoryHotbarSlot
extends PanelContainer

## Thumbnail needs to be updated by tool
signal updated(slot: Variant)

## To Switch block
signal selected(slot: Variant)


@export_group("Internal References")
@export var texture_thumbnail: TextureRect


## The block registry index for this hotbar
var block_index: int = -1:
	get:
		return block_index
	set(value):
		block_index = value
		updated.emit(self)
		return


var preview_texture: Texture:
	set(value):
		texture_thumbnail.texture = value


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			selected.emit(self)


func _get_drag_data(at_position: Vector2) -> Variant:
	return block_index


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is int


func _drop_data(at_position: Vector2, data: Variant) -> void:
	block_index = data
