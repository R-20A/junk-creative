#class_name InventoryBlockItem
extends PanelContainer

## when this item is selected!!
signal selected(item: Variant)


@export_group("Internal References")
@export var texture_thumbnail: TextureRect


var block_index: int = -1


var preview_texture: Texture:
	set(value):
		texture_thumbnail.texture = value



func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_released():
			selected.emit(self)


func _get_drag_data(at_position: Vector2) -> Variant:
	return block_index
