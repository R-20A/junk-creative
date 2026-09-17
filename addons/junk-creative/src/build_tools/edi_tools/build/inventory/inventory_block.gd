class_name InventoryBlock
extends PanelContainer

@export_group("Internal References")
@export var texture_thumbnail: TextureRect

var block_index: int = -1


func _get_drag_data(at_position: Vector2) -> Variant:
	return block_index
